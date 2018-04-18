import Foundation
import NIO
import SwiftLIFX

class LIFXServer: LIFXMessageHandlerDelegate {
    
    // MARK: - Constants
    
    private let macAddress = MacAddress(address: Random.bytes(ofLength: 6))!
    private let firmware = LIFXDevice.Firmware(build: 1511412934000000000, version: 131144)
    private let version = LIFXDevice.Version(vendor: 1, product: 27, hardwareVersion: 0)
    
    // MARK: - Connection
    
    private var handler: LIFXMessageHandler!
    private var channel: Channel!
    private var startedAt: Date!
    
    // MARK: - Delegate
    
    weak var delegate: LIFXServerDelegate?
    
    // MARK: - State
    
    private var label = "LIFXServer" {
        didSet {
            guard oldValue != label else {
                return
            }
            delegate?.didChangeLabel(from: oldValue, to: label, for: self)
        }
    }
    
    private var powerState: LIFXDevice.PowerState = .off {
        didSet {
            guard oldValue != powerState else {
                return
            }
            delegate?.didChangePowerState(from: oldValue, to: powerState, for: self)
        }
    }
    
    private var color = LIFXLight.Color(hue: 0, saturation: 0, brightness: 0, kelvin: 0) {
        didSet {
            guard oldValue != color else {
                return
            }
            delegate?.didChangeColor(from: oldValue, to: color, for: self)
        }
    }
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Run
    
    func run() throws {
        startedAt = Date()
        
        handler = LIFXMessageHandler()
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
    
    private func send(_ message: LIFXMessage, inResponseTo envelope: LIFXParsedEnvelope) {
        var header = LIFXProtocolHeader(for: message)
        header.isTagged = false
        header.source = envelope.header.source
        header.target = macAddress
        header.sequence = envelope.header.sequence
        
        debugPrint("Sending: \(message)")
        _ = channel.writeEnvelope(for: header, message: message, to: envelope.origin)
    }
    
    // MARK: - LIFXMessageHandlerDelegate
    
    func didReceive(envelope: LIFXParsedEnvelope, for handler: LIFXMessageHandler) {
        // Ignore messages not for us
        guard envelope.header.isTagged || envelope.header.target == macAddress else {
            return
        }
        
        debugPrint("Received: \(envelope.message)")
        
        if envelope.header.isAcknowledgementRequired {
            send(LIFXMessages.Acknowledgement(), inResponseTo: envelope)
        }
        
        switch envelope.message {
        case is LIFXMessages.GetService:
            send(LIFXMessages.StateService(), inResponseTo: envelope)
            
        case is LIFXMessages.GetHostInfo:
            send(LIFXMessages.StateHostInfo(), inResponseTo: envelope)
            
        case is LIFXMessages.GetHostFirmware:
            send(LIFXMessages.StateHostFirmware(firmware: firmware), inResponseTo: envelope)
            
        case is LIFXMessages.GetWifiInfo:
            send(LIFXMessages.StateWifiInfo(), inResponseTo: envelope)
            
        case is LIFXMessages.GetWifiFirmware:
            send(LIFXMessages.StateWifiFirmware(firmware: .init(build: 0, version: 0)), inResponseTo: envelope)
            
        case is LIFXMessages.GetPower:
            send(LIFXMessages.StatePower(powerState: powerState), inResponseTo: envelope)
            
        case let message as LIFXMessages.SetPower:
            powerState = message.powerState
            if envelope.header.isResponseRequired {
                send(LIFXMessages.StatePower(powerState: powerState), inResponseTo: envelope)
            }
            
        case is LIFXMessages.GetLabel:
            send(LIFXMessages.StateLabel(label: label), inResponseTo: envelope)
            
        case let message as LIFXMessages.SetLabel:
            label = message.label
            if envelope.header.isResponseRequired {
                send(LIFXMessages.StateLabel(label: label), inResponseTo: envelope)
            }
            
        case is LIFXMessages.GetVersion:
            send(LIFXMessages.StateVersion(version: version), inResponseTo: envelope)
            
        case is LIFXMessages.GetInfo:
            let time = UInt64(Date().timeIntervalSince1970 * 1000000000)
            let uptime = UInt64(Date().timeIntervalSince(startedAt) * 1000000000)
            send(LIFXMessages.StateInfo(time: time, uptime: uptime, downtime: 0), inResponseTo: envelope)
            
        case is LIFXMessages.LightGet:
            send(LIFXMessages.LightState(color: color, powerState: powerState, label: label), inResponseTo: envelope)
            
        case let message as LIFXMessages.LightSetColor:
            color = message.color
            if envelope.header.isResponseRequired {
                send(LIFXMessages.LightState(color: color, powerState: powerState, label: label), inResponseTo: envelope)
            }
            
        case is LIFXMessages.GetPower:
            send(LIFXMessages.LightStatePower(powerState: powerState), inResponseTo: envelope)
            
        case let message as LIFXMessages.LightSetPower:
            powerState = message.powerState
            if envelope.header.isResponseRequired {
                send(LIFXMessages.LightState(color: color, powerState: powerState, label: label), inResponseTo: envelope)
            }
            
        default:
            break
        }
    }
}

protocol LIFXServerDelegate: class {
    func didChangeLabel(from fromLabel: String, to toLabel: String, for server: LIFXServer)
    func didChangePowerState(from fromPowerState: LIFXDevice.PowerState, to toPowerState: LIFXDevice.PowerState, for server: LIFXServer)
    func didChangeColor(from fromColor: LIFXLight.Color, to toColor: LIFXLight.Color, for server: LIFXServer)
}
