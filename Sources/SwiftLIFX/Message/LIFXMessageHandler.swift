import NIO

class LIFXMessageHandler: ChannelInboundHandler {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    
    weak var delegate: LIFXMessageHandlerDelegate?

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var envelope = unwrapInboundIn(data)
        let headerBytes = envelope.data.readBytes(length: LIFXProtocolHeader.size) ?? []
        let payloadBytes = envelope.data.readBytes(length: envelope.data.readableBytes) ?? []
        
        do {
            let header = try LIFXProtocolHeader(bytes: headerBytes)
            guard headerBytes.count + payloadBytes.count == header.size else {
                throw LIFXMessageParsingError("Invalid packet size")
            }
            
            guard let messageType = LIFXMessageTypes.mapping[header.type] else {
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

    func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }

    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        ctx.close(promise: nil)
    }
}

struct LIFXParsedEnvelope {
    var header: LIFXProtocolHeader
    var message: LIFXMessage
    var origin: SocketAddress
}

protocol LIFXMessageHandlerDelegate: class {
    func didReceive(envelope: LIFXParsedEnvelope, for handler: LIFXMessageHandler)
}
