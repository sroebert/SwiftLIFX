import NIO

public class LIFXMessageHandler: ChannelInboundHandler {
    
    // MARK: - Properties
    
    public weak var delegate: LIFXMessageHandlerDelegate?
    
    // MARK: - Init
    
    public init() {
        
    }
    
    // MARK: - ChannelInboundHandler
    
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var envelope = unwrapInboundIn(data)
        let headerBytes = envelope.data.readBytes(length: LIFXProtocolHeader.size) ?? []
        let payloadBytes = envelope.data.readBytes(length: envelope.data.readableBytes) ?? []
        
        do {
            let header = try LIFXProtocolHeader(bytes: headerBytes)
            guard headerBytes.count + payloadBytes.count == header.size else {
                throw LIFXMessageParsingError("Invalid packet size")
            }
            
            guard let messageType = LIFXMessages.mapping[header.type] else {
                debugPrint("Received unknown message with type: \(header.type)")
                throw LIFXMessageParsingError("Unknown message type \(header.type)")
            }
            
            let message = try messageType.init(payload: payloadBytes)
            let parsedEnvelope = LIFXParsedEnvelope(header: header, message: message, origin: envelope.remoteAddress)
            delegate?.didReceive(envelope: parsedEnvelope, for: self)
        } catch {
            // Failed to parse message
        }
    }

    public func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }

    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        ctx.close(promise: nil)
    }
}

public struct LIFXParsedEnvelope {
    public var header: LIFXProtocolHeader
    public var message: LIFXMessage
    public var origin: SocketAddress
    
    public init(header: LIFXProtocolHeader, message: LIFXMessage, origin: SocketAddress) {
        self.header = header
        self.message = message
        self.origin = origin
    }
}

public protocol LIFXMessageHandlerDelegate: class {
    func didReceive(envelope: LIFXParsedEnvelope, for handler: LIFXMessageHandler)
}
