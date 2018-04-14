import Foundation
import NIO

struct LIFXMessageClient {
    
    // MARK: - Constants
    
    private static let broadcastPort: UInt16 = 56700
    
    // MARK: - Types
    
    private struct UntypedResponse {
        var origin: SocketAddress
        var header: LIFXProtocolHeader
        var message: LIFXMessage
        
        func convert<Message: LIFXMessage>(to otherType: Message.Type) throws -> Response<Message> {
            guard let convertedMessage = message as? Message else {
                throw LIFXMessageParsingError("Invalid response type received \(type(of: message)).")
            }
            return Response(origin: origin, header: header, message: convertedMessage)
        }
    }
    
    struct Response<Message: LIFXMessage> {
        var origin: SocketAddress
        var header: LIFXProtocolHeader
        var message: Message
        
        var device: LIFXDevice? {
            guard let macAddress = header.target else {
                return nil
            }
            return LIFXDevice(macAddress: macAddress, socketAddress: origin)
        }
    }
    
    private struct SendConfiguration {
        var device: LIFXDevice?
        var source: UInt32
        var isAcknowledgementRequired: Bool
        var isResponseRequired: Bool
        var socketAddress: SocketAddress
        var group: EventLoopGroup
    }
    
    // MARK: - Send
    
    @discardableResult
    static func send(_ message: LIFXMessage, for device: LIFXDevice? = nil, source: UInt32) -> EventLoopFuture<Void> {
        let group = MultiThreadedEventLoopGroup(numThreads: 1)
        let addresses = socketAddresses(for: device)
        let futures = addresses.map { address in
            send(message, for: device, source: source, to: address, using: group)
        }
        return EventLoopFuture<Void>.andAll(futures, eventLoop: group.next()).thenThrowing {
            try group.syncShutdownGracefully()
        }
    }
    
    static func send<Message: LIFXMessage>(_ message: LIFXMessage, for device: LIFXDevice, source: UInt32, responseType: Message.Type, timeout: TimeAmount = .seconds(2)) -> EventLoopFuture<Response<Message>> {
        let group = MultiThreadedEventLoopGroup(numThreads: 1)
        
        var addresses = socketAddresses(for: device)
        guard !addresses.isEmpty else {
            return group.next().newFailedFuture(error: LIFXMessageParsingError("No broadcast addresses found."))
        }
        
        let firstAddress = addresses.removeFirst()
        var future = send(message, for: device, source: source, responseType: Message.self, timeout: timeout, to: firstAddress, using: group)
        for address in addresses {
            future = future.thenIfError { _ in
                send(message, for: device, source: source, responseType: Message.self, timeout: timeout, to: address, using: group)
            }
        }
        return future.thenThrowing { result in
            try group.syncShutdownGracefully()
            return result
        }
    }
    
    static func send<Message: LIFXMessage>(_ message: LIFXMessage, source: UInt32, responseType: Message.Type, timeout: TimeAmount = .seconds(2)) -> EventLoopFuture<[Response<Message>]> {
        let group = MultiThreadedEventLoopGroup(numThreads: 1)
        let addresses = socketAddresses(for: nil)
        let futures = addresses.map { address in
            send(message, source: source, responseType: Message.self, timeout: timeout, to: address, using: group)
        }
        
        let promise: EventLoopPromise<[Response<Message>]> = group.next().newPromise()
        let future = futures.reduce(promise.futureResult) { f1, f2 in
            return f1.and(f2).map { tuple in
                return tuple.0 + tuple.1
            }
        }
        promise.succeed(result: [])
        return future
    }
    
    // MARK: - Utils
    
    private static func getBroadcastAddresses() throws -> [SocketAddress] {
        return try System.enumerateInterfaces().compactMap { interface in
            guard let broadcastAddress = interface.broadcastAddress else {
                return nil
            }
            
            switch broadcastAddress {
            case .v4(let ipv4Address):
                return try? SocketAddress(ipAddress: ipv4Address.host, port: broadcastPort)
                
            case .v6(let ipv6Address):
                return try? SocketAddress(ipAddress: ipv6Address.host, port: broadcastPort)
                
            case .unixDomainSocket:
                return nil
            }
        }
    }
    
    private static func socketAddresses(for device: LIFXDevice?) -> [SocketAddress] {
        if let socketAddress = device?.socketAddress {
            return [socketAddress]
        } else if let addresses = try? getBroadcastAddresses() {
            return addresses
        } else {
            return []
        }
    }
    
    private static func send(_ message: LIFXMessage, for device: LIFXDevice?, source: UInt32, to socketAddress: SocketAddress, using group: EventLoopGroup) -> EventLoopFuture<Void> {
        
        let configuration = SendConfiguration(
            device: device,
            source: source,
            isAcknowledgementRequired: false,
            isResponseRequired: false,
            socketAddress: socketAddress,
            group: group
        )
        
        return send(message, using: configuration).map { _ in }
    }
    
    private static func send<Message: LIFXMessage>(_ message: LIFXMessage, for device: LIFXDevice, source: UInt32, responseType: Message.Type, timeout: TimeAmount, to socketAddress: SocketAddress, using group: EventLoopGroup) -> EventLoopFuture<Response<Message>> {
        
        let configuration = SendConfiguration(
            device: device,
            source: source,
            isAcknowledgementRequired: responseType == AcknowledgementLIFXMessage.self,
            isResponseRequired: responseType != AcknowledgementLIFXMessage.self,
            socketAddress: socketAddress,
            group: group
        )
        
        return send(message, using: configuration).then { handler -> EventLoopFuture<Handler> in
            let promise: EventLoopPromise<Handler> = group.next().newPromise()
            _ = group.next().scheduleTask(in: timeout) {
                promise.succeed(result: handler)
            }
            return promise.futureResult
        }.thenThrowing { handler -> Response<Message> in
            guard let response = handler.parsedResponses.first else {
                if let error = handler.parsedErrors.first {
                    throw error
                }
                throw LIFXMessageParsingError("No response received.")
            }
            return try response.convert(to: Message.self)
        }
    }
    
    private static func send<Message: LIFXMessage>(_ message: LIFXMessage, source: UInt32, responseType: Message.Type, timeout: TimeAmount, to socketAddress: SocketAddress, using group: EventLoopGroup) -> EventLoopFuture<[Response<Message>]> {
        
        let configuration = SendConfiguration(
            device: nil,
            source: source,
            isAcknowledgementRequired: responseType == AcknowledgementLIFXMessage.self,
            isResponseRequired: responseType != AcknowledgementLIFXMessage.self,
            socketAddress: socketAddress,
            group: group
        )
        
        return send(message, using: configuration).then { handler -> EventLoopFuture<Handler> in
            let promise: EventLoopPromise<Handler> = group.next().newPromise()
            _ = group.next().scheduleTask(in: timeout) {
                promise.succeed(result: handler)
            }
            return promise.futureResult
        }.thenThrowing { handler -> [Response<Message>] in
            return handler.parsedResponses.compactMap { try? $0.convert(to: Message.self) }
        }
    }
    
    private static func send(_ message: LIFXMessage, using configuration: SendConfiguration) -> EventLoopFuture<Handler> {
        
        let resultHandler = Handler()
        let bootstrap = DatagramBootstrap(group: configuration.group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_BROADCAST), value: 1)
            .channelInitializer { channel in
                channel.pipeline.add(handler: resultHandler)
            }
        
        var header = LIFXProtocolHeader(type: type(of: message).id)
        header.isTagged = configuration.device == nil
        header.source = configuration.source
        header.target = configuration.device?.macAddress
        header.isAcknowledgementRequired = configuration.isAcknowledgementRequired
        header.isResponseRequired = configuration.isResponseRequired
        
        let payload = message.encode()
        header.size = LIFXProtocolHeader.size + payload.count
        
        let headerData = header.encode()
        
        return bootstrap.bind(host: "0.0.0.0", port: 0).then { channel -> EventLoopFuture<Void> in
            var buffer = channel.allocator.buffer(capacity: header.size)
            buffer.write(bytes: headerData)
            buffer.write(bytes: payload)
            
            let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: configuration.socketAddress, data: buffer)
            return channel.writeAndFlush(envelope)
        }.thenThrowing {
            return resultHandler
        }
    }
    
    // MARK: - Handler
    
    private class Handler: ChannelInboundHandler {
        public typealias InboundIn = AddressedEnvelope<ByteBuffer>
        public typealias OutboundOut = AddressedEnvelope<ByteBuffer>
        
        public var parsedResponses: [UntypedResponse] = []
        public var parsedErrors: [Error] = []
        
        public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
            var envelope = unwrapInboundIn(data)
            let headerBytes = envelope.data.readBytes(length: LIFXProtocolHeader.size) ?? []
            let payloadBytes = envelope.data.readBytes(length: envelope.data.readableBytes) ?? []
            
            do {
                let header = try LIFXProtocolHeader(bytes: headerBytes)
                guard headerBytes.count + payloadBytes.count == header.size else {
                    throw LIFXMessageParsingError("Invalid packet size")
                }
                
                guard let messageType = LIFXMessageTypes.mapping[header.type] else {
                    throw LIFXMessageParsingError("Unknown message type \(header.type)")
                }
                
                let message = try messageType.init(payload: payloadBytes)
                let response = UntypedResponse(
                    origin: envelope.remoteAddress,
                    header: header,
                    message: message
                )
                parsedResponses.append(response)
            } catch {
                parsedErrors.append(error)
            }
        }
        
        public func channelReadComplete(ctx: ChannelHandlerContext) {
            ctx.flush()
        }

        public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
            ctx.close(promise: nil)
        }
    }
}
