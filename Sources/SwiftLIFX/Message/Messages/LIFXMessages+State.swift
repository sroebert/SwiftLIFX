import Foundation

extension LIFXMessages {
    public final class StateService: LIFXMessage {
        
        // MARK: - Properties
        
        public let service: LIFXDevice.Service
        public let port: UInt32
        
        // MARK: - Init
        
        public init(service: LIFXLight.Service = .udp, port: UInt32 = UInt32(LIFXConstants.broadcastPort)) {
            self.service = service
            self.port = port
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            (service, port) = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(service, port)
        }
    }
    
    public final class StateLabel: LIFXMessage {
        
        // MARK: - Properties
        
        public let label: String
        
        // MARK: - Init
        
        public init(label: String) {
            self.label = label
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            label = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(label)
        }
    }
    
    public class StateSignalInfo: LIFXMessage {
        
        // MARK: - Properties
        
        public let signal: Float32
        public let tx: UInt32
        public let rx: UInt32
        
        // MARK: - Init
        
        public init(signal: Float32 = 0, tx: UInt32 = 0, rx: UInt32 = 0) {
            self.signal = signal
            self.tx = tx
            self.rx = rx
        }
        
        // MARK: - LIFXMessage
        
        public required init(payload: [UInt8]) throws {
            (signal, tx, rx) = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(signal, tx, rx)
        }
    }
    
    public final class StateHostInfo: StateSignalInfo {
        
    }
    
    public final class StateWifiInfo: StateSignalInfo {
        
    }
    
    public class StateFirmware: LIFXMessage {
        
        // MARK: - Properties
        
        public let firmware: LIFXDevice.Firmware
        
        // MARK: - Init
        
        public init(firmware: LIFXDevice.Firmware) {
            self.firmware = firmware
        }
        
        // MARK: - LIFXMessage
        
        public required init(payload: [UInt8]) throws {
            firmware = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(firmware)
        }
    }
    
    public final class StateHostFirmware: StateFirmware {
        
    }
    
    public final class StateWifiFirmware: StateFirmware {
        
    }
    
    public final class StateVersion: LIFXMessage {
        
        // MARK: - Properties
        
        public let version: LIFXDevice.Version
        
        // MARK: - Init
        
        public init(version: LIFXDevice.Version) {
            self.version = version
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            version = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(version)
        }
    }
    
    public final class StateInfo: LIFXMessage {
        
        // MARK: - Properties
        
        public let time: UInt64
        public let uptime: UInt64
        public let downtime: UInt64
        
        // MARK: - Init
        
        public init(time: UInt64, uptime: UInt64, downtime: UInt64) {
            self.time = time
            self.uptime = uptime
            self.downtime = downtime
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            (time, uptime, downtime) = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(time, uptime, downtime)
        }
    }
    
    public final class LightState: LIFXMessage {
        
        // MARK: - Properties
        
        public let state: LIFXLight.State
        
        // MARK: - Init
        
        public init(state: LIFXLight.State) {
            self.state = state
        }
        
        public init(color: LIFXLight.Color, powerState: LIFXDevice.PowerState, label: String) {
            state = LIFXLight.State(color: color, powerState: powerState, label: label)
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            state = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(state)
        }
    }
    
    public class StatePower: LIFXMessage {
        
        // MARK: - Properties
        
        public let powerState: LIFXDevice.PowerState
        
        // MARK: - Init
        
        public init(powerState: LIFXDevice.PowerState) {
            self.powerState = powerState
        }
        
        // MARK: - LIFXMessage
        
        public required init(payload: [UInt8]) throws {
            powerState = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(powerState)
        }
    }
    
    public final class LightStatePower: StatePower {
        
    }
}
