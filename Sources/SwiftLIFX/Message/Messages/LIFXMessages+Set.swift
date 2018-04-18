import Foundation

extension LIFXMessages {
    public final class SetPower: LIFXMessage {
        
        // MARK: - Properties
        
        public let powerState: LIFXDevice.PowerState
        
        // MARK: - Init
        
        public init(powerState: LIFXDevice.PowerState) {
            self.powerState = powerState
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            powerState = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(powerState)
        }
    }
    
    public final class SetLabel: LIFXMessage {
        
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
    
    public final class LightSetColor: LIFXMessage {
        
        // MARK: - Properties
        
        let reserved: UInt8
        public let color: LIFXLight.Color
        public let duration: UInt32
        
        // MARK: - Init
        
        public init(color: LIFXLight.Color, duration: UInt32 = 0) {
            reserved = 0
            self.color = color
            self.duration = duration
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            (reserved, color, duration) = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(reserved, color, duration)
        }
    }
    
    public final class LightSetPower: LIFXMessage {
        
        // MARK: - Properties
        
        public let powerState: LIFXDevice.PowerState
        public let duration: UInt32
        
        // MARK: - Init
        
        public init(powerState: LIFXDevice.PowerState, duration: UInt32 = 0) {
            self.powerState = powerState
            self.duration = duration
        }
        
        // MARK: - LIFXMessage
        
        public init(payload: [UInt8]) throws {
            (powerState, duration) = try ByteUtils.decode(payload)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(powerState, duration)
        }
    }
}
