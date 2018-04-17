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
        var header = LIFXProtocolHeader(for: message)
        header.isTagged = false
        header.source = request.header.source
        header.target = macAddress
        header.sequence = request.header.sequence
        
        debugPrint("Sending: \(message)")
        _ = channel.writeEnvelope(for: header, message: message, to: request.origin)
    }
    
    // MARK: - LIFXServerHandlerDelegate
    
    fileprivate func didReceive(request: LIFXServerRequest, for handler: LIFXServerHandler) {
        // Ignore messages not for us
        guard request.header.isTagged || request.header.target == macAddress else {
            return
        }
        
        debugPrint("Received: \(request.message)")
        
        if request.header.isAcknowledgementRequired {
            send(LIFXMessages.Acknowledgement(), inResponseTo: request)
        }
        
        switch request.message {
        case is LIFXMessages.GetService:
            send(LIFXMessages.StateService(), inResponseTo: request)
            
        case is LIFXMessages.GetHostInfo:
            send(LIFXMessages.StateHostInfo(), inResponseTo: request)
            
        case is LIFXMessages.GetHostFirmware:
            send(LIFXMessages.StateHostFirmware(firmware: firmware), inResponseTo: request)
            
        case is LIFXMessages.GetWifiInfo:
            send(LIFXMessages.StateWifiInfo(), inResponseTo: request)
            
        case is LIFXMessages.GetWifiFirmware:
            send(LIFXMessages.StateWifiFirmware(firmware: .init(build: 0, version: 0)), inResponseTo: request)
            
        case is LIFXMessages.GetPower:
            send(LIFXMessages.StatePower(powerState: powerState), inResponseTo: request)
            
        case let message as LIFXMessages.SetPower:
            powerState = message.powerState
            if request.header.isResponseRequired {
                send(LIFXMessages.StatePower(powerState: powerState), inResponseTo: request)
            }
            
        case is LIFXMessages.GetLabel:
            send(LIFXMessages.StateLabel(label: label), inResponseTo: request)
            
        case let message as LIFXMessages.SetLabel:
            label = message.label
            if request.header.isResponseRequired {
                send(LIFXMessages.StateLabel(label: label), inResponseTo: request)
            }
            
        case is LIFXMessages.GetVersion:
            send(LIFXMessages.StateVersion(version: version), inResponseTo: request)
            
        case is LIFXMessages.GetInfo:
            let time = UInt64(Date().timeIntervalSince1970 * 1000000000)
            let uptime = UInt64(Date().timeIntervalSince(startedAt) * 1000000000)
            send(LIFXMessages.StateInfo(time: time, uptime: uptime, downtime: 0), inResponseTo: request)
            
        case is LIFXMessages.GetLightState:
            send(LIFXMessages.StateLight(color: color, powerState: powerState, label: label), inResponseTo: request)
            
        case let message as LIFXMessages.SetLightColor:
            color = message.color
            if request.header.isResponseRequired {
                send(LIFXMessages.StateLight(color: color, powerState: powerState, label: label), inResponseTo: request)
            }
            
        case is LIFXMessages.GetPower:
            send(LIFXMessages.StatePowerLight(powerState: powerState), inResponseTo: request)
            
        case let message as LIFXMessages.SetPowerLight:
            powerState = message.powerState
            if request.header.isResponseRequired {
                send(LIFXMessages.StateLight(color: color, powerState: powerState, label: label), inResponseTo: request)
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
            
            guard let messageType = LIFXMessages.mapping[header.type] else {
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
