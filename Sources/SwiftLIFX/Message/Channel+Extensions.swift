import NIO

extension Channel {
    public func writeEnvelope(for header: LIFXProtocolHeader, message: LIFXMessage, to socketAddress: SocketAddress) -> EventLoopFuture<Void> {
        let payload = message.encode()
        
        var header = header
        header.size = LIFXProtocolHeader.size + payload.count
        let headerBytes = header.encode()
        
        var buffer = allocator.buffer(capacity: header.size)
        buffer.write(bytes: headerBytes)
        buffer.write(bytes: payload)
        
        let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: socketAddress, data: buffer)
        return writeAndFlush(envelope)
    }
}
