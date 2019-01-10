import Foundation
import NIO

public class LIFXClient: LIFXMessageHandlerDelegate {
    
    // MARK: - Types
    
    private struct SendConfiguration {
        var device: LIFXDevice?
        var isAcknowledgementRequired: Bool
        var isResponseRequired: Bool
        var sequence: UInt8
        var socketAddress: SocketAddress
    }
    
    public struct Response<Message: LIFXMessage> {
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
    
    public enum ResponseError {
        case tooManyRequests
    }
    
    // MARK: - Properties
    
    public let source: UInt32
    
    private let group: EventLoopGroup
    private var handler: LIFXMessageHandler?
    
    private var channelConnectingFuture: EventLoopFuture<Channel>?
    private var channel: Channel?
    
    private var currentSequence: UInt8 = 0
    
    private var singleResponsePromises: [UInt8: EventLoopPromise<LIFXParsedEnvelope>] = [:]
    
    private var multiResponsePromises: [UInt8: EventLoopPromise<[LIFXParsedEnvelope]>] = [:]
    private var multiResponseEnvelopes: [UInt8: [LIFXParsedEnvelope]] = [:]
    
    // MARK: - Init
    
    public init(source: UInt32) {
        self.source = source
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    // MARK: - Deinit
    
    deinit {
        _ = channel?.close(mode: .all)
        try? group.syncShutdownGracefully()
    }
    
    // MARK: - Send
    
    @discardableResult
    public func send(_ message: LIFXMessage, for device: LIFXDevice? = nil) -> EventLoopFuture<Void> {
        return getSequence().then { sequence in
            self.send(message, for: device, sequence: sequence, isAcknowledgementRequired: false, isResponseRequired: false)
        }
    }
    
    public func send<Message: LIFXMessage>(_ message: LIFXMessage, for device: LIFXDevice, responseType: Message.Type, timeout: TimeAmount = .seconds(2)) -> EventLoopFuture<Response<Message>> {
        return getSequence().then { sequence in
            let responseFuture = self.getSingleResponseFuture(forSequence: sequence, responseType: responseType, timeout: timeout)
            let isAcknowledgementRequired = responseType == LIFXMessages.Acknowledgement.self
            let isResponseRequired = responseType != LIFXMessages.Acknowledgement.self
            return self.send(message, for: device, sequence: sequence, isAcknowledgementRequired: isAcknowledgementRequired, isResponseRequired: isResponseRequired).then {
                responseFuture
            }
        }
    }
    
    public func send<Message: LIFXMessage>(_ message: LIFXMessage, responseType: Message.Type, timeout: TimeAmount = .seconds(2)) -> EventLoopFuture<[Response<Message>]> {
        return getSequence().then { sequence in
            let responseFuture = self.getMultiResponseFuture(forSequence: sequence, responseType: responseType, timeout: timeout)
            let isAcknowledgementRequired = responseType == LIFXMessages.Acknowledgement.self
            let isResponseRequired = responseType != LIFXMessages.Acknowledgement.self
            return self.send(message, for: nil, sequence: sequence, isAcknowledgementRequired: isAcknowledgementRequired, isResponseRequired: isResponseRequired).then {
                responseFuture
            }
        }
    }
    
    // MARK: - Private Send
    
    private func send(_ message: LIFXMessage, for device: LIFXDevice?, sequence: UInt8, isAcknowledgementRequired: Bool, isResponseRequired: Bool) -> EventLoopFuture<Void> {
        return group.next().submit {
            try self.socketAddress(for: device)
        }.then { address in
            return self.send(message, using: SendConfiguration(
                device: device,
                isAcknowledgementRequired: isAcknowledgementRequired,
                isResponseRequired: isResponseRequired,
                sequence: sequence,
                socketAddress: address
            ))
        }
    }
    
    private func send(_ message: LIFXMessage, using configuration: SendConfiguration) -> EventLoopFuture<Void> {
        return getChannel().then { channel in
            
            var header = self.header(for: message, using: configuration)
            let payload = message.encode()
            header.size = LIFXProtocolHeader.size + payload.count
            
            let headerData = header.encode()
            
            var buffer = channel.allocator.buffer(capacity: header.size)
            buffer.write(bytes: headerData)
            buffer.write(bytes: payload)
            
            let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: configuration.socketAddress, data: buffer)
            return channel.writeAndFlush(envelope)
        }
    }
    
    // MARK: - Utils
    
    private func socketAddress(for device: LIFXDevice?) throws -> SocketAddress {
        if let socketAddress = device?.socketAddress {
            return socketAddress
        } else {
            return try SocketAddress(ipAddress: "255.255.255.255", port: LIFXConstants.broadcastPort)
        }
    }
    
    private func getSequence() -> EventLoopFuture<UInt8> {
        return group.next().submit {
            let sequence = self.currentSequence
            self.currentSequence = self.currentSequence &+ 1
            return sequence
        }
    }
    
    private func header(for message: LIFXMessage, using configuration: SendConfiguration) -> LIFXProtocolHeader {
        var header = LIFXProtocolHeader(for: message)
        header.isTagged = configuration.device == nil
        header.source = self.source
        header.target = configuration.device?.macAddress
        header.isAcknowledgementRequired = configuration.isAcknowledgementRequired
        header.isResponseRequired = configuration.isResponseRequired
        header.sequence = configuration.sequence
        return header
    }
    
    // MARK: - Socket
    
    public var isSocketActive: Bool {
        if group.next().inEventLoop {
            return channel?.isActive == true
        } else {
            do {
                return try group.next().submit {
                    return self.channel?.isActive == true
                }.wait()
            } catch {
                return false
            }
        }
    }
    
    public func closeSocket() {
        _ = group.next().submit {
            guard let channel = self.channel else {
                return
            }
            
            try? channel.close(mode: .all).wait()
            self.channel = nil
            
            self.handler?.delegate = nil
            self.handler = nil
        }
    }
    
    private func connectSocket() -> EventLoopFuture<(channel: Channel, handler: LIFXMessageHandler)> {
        let handler = LIFXMessageHandler()
        let bootstrap = DatagramBootstrap(group: self.group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_BROADCAST), value: 1)
            .channelInitializer { channel in
                channel.pipeline.add(handler: handler)
            }
        
        return bootstrap.bind(host: "0.0.0.0", port: 0).map { ($0, handler) }
    }
    
    private func getChannel() -> EventLoopFuture<Channel> {
        let promise: EventLoopPromise<Channel> = group.next().newPromise()
        
        _ = group.next().submit { () -> Void in
            if let channel = self.channel {
                promise.succeed(result: channel)
                return
            }
            
            if let future = self.channelConnectingFuture {
                future.cascade(promise: promise)
                return
            }
            
            let future = self.connectSocket().thenThrowing { (channel, handler) -> Channel in
                handler.delegate = self
                self.channel = channel
                self.handler = handler
                self.channelConnectingFuture = nil
                return channel
            }
            self.channelConnectingFuture = future
            future.cascade(promise: promise)
        }
        
        return promise.futureResult
    }
    
    // MARK: - Responses
    
    private func clearPromises(forSequence sequence: UInt8) {
        let error = LIFXMessageParsingError("Too many requests")
        if let promise = singleResponsePromises[sequence] {
            promise.fail(error: error)
            singleResponsePromises[sequence] = nil
        }
        
        if let promise = multiResponsePromises[sequence] {
            promise.fail(error: error)
            multiResponsePromises[sequence] = nil
            multiResponseEnvelopes[sequence] = nil
        }
    }
    
    private func setupCleaning<T>(for future: EventLoopFuture<T>, sequence: UInt8) {
        future.whenSuccess { _ in
            self.clearPromises(forSequence: sequence)
        }
        future.whenFailure { error in
            guard (error as? ResponseError) != .tooManyRequests else {
                return
            }
            self.clearPromises(forSequence: sequence)
        }
    }
    
    private func getSingleResponseFuture<Message: LIFXMessage>(forSequence sequence: UInt8, responseType: Message.Type, timeout: TimeAmount) -> EventLoopFuture<Response<Message>> {
        
        clearPromises(forSequence: sequence)
        
        let promise: EventLoopPromise<LIFXParsedEnvelope> = group.next().newPromise()
        singleResponsePromises[sequence] = promise
        
        _ = group.next().scheduleTask(in: timeout) {
            promise.fail(error: LIFXMessageParsingError("No response received."))
        }
        
        let future = promise.futureResult.thenThrowing { try $0.convert(to: responseType) }
        setupCleaning(for: future, sequence: sequence)
        return future
    }
    
    private func getMultiResponseFuture<Message: LIFXMessage>(forSequence sequence: UInt8, responseType: Message.Type, timeout: TimeAmount) -> EventLoopFuture<[Response<Message>]> {
        
        clearPromises(forSequence: sequence)
        
        let promise: EventLoopPromise<[LIFXParsedEnvelope]> = group.next().newPromise()
        multiResponsePromises[sequence] = promise
        multiResponseEnvelopes[sequence] = []
        
        _ = group.next().scheduleTask(in: timeout) {
            let envelopes = self.multiResponseEnvelopes[sequence]
            promise.succeed(result: envelopes ?? [])
        }
        
        let future = promise.futureResult.thenThrowing { try $0.convert(to: responseType) }
        setupCleaning(for: future, sequence: sequence)
        return future
    }
    
    // MARK: - LIFXMessageHandlerDelegate
    
    public func didReceive(envelope: LIFXParsedEnvelope, for handler: LIFXMessageHandler) {
        if let promise = singleResponsePromises[envelope.header.sequence] {
            promise.succeed(result: envelope)
        } else if var responses = multiResponseEnvelopes[envelope.header.sequence] {
            responses.append(envelope)
            multiResponseEnvelopes[envelope.header.sequence] = responses
        }
    }
}

extension LIFXParsedEnvelope {
    fileprivate func convert<Message: LIFXMessage>(to messageType: Message.Type) throws -> LIFXClient.Response<Message> {
        guard let convertedMessage = message as? Message else {
            throw LIFXMessageParsingError("Invalid response type received \(type(of: message)).")
        }
        return LIFXClient.Response(origin: origin, header: header, message: convertedMessage)
    }
}

extension Collection where Element == LIFXParsedEnvelope {
    fileprivate func convert<Message: LIFXMessage>(to messageType: Message.Type) throws -> [LIFXClient.Response<Message>] {
        return try compactMap { try $0.convert(to: messageType) }
    }
}
