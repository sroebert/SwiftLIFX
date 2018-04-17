import Foundation
import NIO

public class LIFXServer: LIFXServerHandlerDelegate {
    
    // MARK: - Constants
    
    private let macAddress = MacAddress(address: Random.bytes(ofLength: 6))!
    private let firmware = LIFXDevice.Firmware(build: 1511412934000000000, version: 131144)
    private let version = LIFXDevice.Version(vendor: 1, product: 27, hardwareVersion: 0)
    
    // MARK: - Connection
    
    private var handler: LIFXServerHandler!
    private var channel: Channel!
    private var startedAt: Date!
    
    // MARK: - State
    
    private var label = "LIFXServer"
    private var powerState: LIFXDevice.PowerState = .off
    private var color = LIFXLight.Color(hue: 0, saturation: 0, brightness: 0, kelvin: 0)
    
    // MARK: - Init
    
    public init() {
        
    }
    
    // MARK: - Run
    
    public func run() throws {
        startedAt = Date()
        
        handler = LIFXServerHandler()
        handler.delegate = self
        
        let group = MultiThreadedEventLoopGroup(numThreads: 1)
        let bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                channel.pipeline.add(handler: self.handler)
            }
        defer {
            try! group.syncShutdownGracefully()
        }
        
        channel = try! bootstrap.bind(host: "0.0.0.0", port: Int(LIFXConstants.broadcastPort)).wait()
        
        try channel.closeFuture.wait()
    }
    
    // MARK: - Send
    
    private func send(_ message: LIFXMessage, inResponseTo request: LIFXServerRequest) {
        let payload = message.encode()
        
        var header = LIFXProtocolHeader(type: type(of: message).id)
        header.size = LIFXProtocolHeader.size + payload.count
        header.isTagged = false
        header.source = request.header.source
        header.target = macAddress
        header.sequence = request.header.sequence
        let headerBytes = header.encode()
        
        var buffer = channel.allocator.buffer(capacity: header.size)
        buffer.write(bytes: headerBytes)
        buffer.write(bytes: payload)
        
        debugPrint("Sending: \(message)")
        
        let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: request.origin, data: buffer)
        _ = channel.writeAndFlush(envelope)
    }
    
    // MARK: - LIFXServerHandlerDelegate
    
    fileprivate func didReceive(request: LIFXServerRequest, for handler: LIFXServerHandler) {
        // Ignore messages not for us
        guard request.header.isTagged || request.header.target == macAddress else {
            return
        }
        
        debugPrint("Received: \(request.message)")
        
        if request.header.isAcknowledgementRequired {
            send(AcknowledgementLIFXMessage(), inResponseTo: request)
        }
        
        switch request.message {
        case is GetServiceLIFXMessage:
            send(StateServiceLIFXMessage(), inResponseTo: request)
            
        case is GetHostInfoLIFXMessage:
            send(StateHostInfoLIFXMessage(), inResponseTo: request)
            
        case is GetHostFirmwareLIFXMessage:
            send(StateHostFirmwareLIFXMessage(firmware: firmware), inResponseTo: request)
            
        case is GetWifiInfoLIFXMessage:
            send(StateWifiInfoLIFXMessage(), inResponseTo: request)
            
        case is GetWifiFirmwareLIFXMessage:
            send(StateWifiFirmwareLIFXMessage(firmware: .init(build: 0, version: 0)), inResponseTo: request)
            
        case is GetPowerLIFXMessage:
            send(StatePowerLIFXMessage(powerState: powerState), inResponseTo: request)
            
        case let message as SetPowerLIFXMessage:
            powerState = message.powerState
            if request.header.isResponseRequired {
                send(StatePowerLIFXMessage(powerState: powerState), inResponseTo: request)
            }
            
        case is GetLabelLIFXMessage:
            send(StateLabelLIFXMessage(label: label), inResponseTo: request)
            
        case let message as SetLabelLIFXMessage:
            label = message.label
            if request.header.isResponseRequired {
                send(StateLabelLIFXMessage(label: label), inResponseTo: request)
            }
            
        case is GetVersionLIFXMessage:
            send(StateVersionLIFXMessage(version: version), inResponseTo: request)
            
        case is GetInfoLIFXMessage:
            let time = UInt64(Date().timeIntervalSince1970 * 1000000000)
            let uptime = UInt64(Date().timeIntervalSince(startedAt) * 1000000000)
            send(StateInfoLIFXMessage(time: time, uptime: uptime, downtime: 0), inResponseTo: request)
            
        case is GetLightStateLIFXMessage:
            send(StateLightLIFXMessage(color: color, powerState: powerState, label: label), inResponseTo: request)
            
        case let message as SetLightColorLIFXMessage:
            color = message.color
            if request.header.isResponseRequired {
                send(StateLightLIFXMessage(color: color, powerState: powerState, label: label), inResponseTo: request)
            }
            
        case is GetPowerLIFXMessage:
            send(StatePowerLightLIFXMessage(powerState: powerState), inResponseTo: request)
            
        case let message as SetPowerLightLIFXMessage:
            powerState = message.powerState
            if request.header.isResponseRequired {
                send(StateLightLIFXMessage(color: color, powerState: powerState, label: label), inResponseTo: request)
            }
            
        default:
            break
        }
    }
}

private struct LIFXServerRequest {
    var header: LIFXProtocolHeader
    var message: LIFXMessage
    var origin: SocketAddress
}

private class LIFXServerHandler: ChannelInboundHandler {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    
    weak var delegate: LIFXServerHandlerDelegate?

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var envelope = unwrapInboundIn(data)
        let headerBytes = envelope.data.readBytes(length: LIFXProtocolHeader.size) ?? []
        let payloadBytes = envelope.data.readBytes(length: envelope.data.readableBytes) ?? []
        
        do {
            let header = try LIFXProtocolHeader(bytes: headerBytes)
            guard header.source == 1768386412 else { // logi
                // ignore if not from logi
                return
            }
            
            guard headerBytes.count + payloadBytes.count == header.size else {
                throw LIFXMessageParsingError("Invalid packet size")
            }
            
            guard let messageType = LIFXMessageTypes.mapping[header.type] else {
                debugPrint("Received unknown message with type: \(header.type)")
                throw LIFXMessageParsingError("Unknown message type \(header.type)")
            }
            
            let message = try messageType.init(payload: payloadBytes)
            let request = LIFXServerRequest(header: header, message: message, origin: envelope.remoteAddress)
            delegate?.didReceive(request: request, for: self)
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

private protocol LIFXServerHandlerDelegate: class {
    func didReceive(request: LIFXServerRequest, for handler: LIFXServerHandler)
}
