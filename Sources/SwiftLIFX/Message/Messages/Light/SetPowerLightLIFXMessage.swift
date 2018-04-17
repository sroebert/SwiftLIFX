import Foundation

extension LIFXMessages {
    public struct SetPowerLight: LIFXMessage {
        
        // MARK: - Properties
        
        public var powerState: LIFXDevice.PowerState
        public var duration: UInt32
        
        // MARK: - Init
        
        public init(powerState: LIFXDevice.PowerState, duration: UInt32 = 0) {
            self.powerState = powerState
            self.duration = duration
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 117
        
        public init(payload: [UInt8]) throws {
            let powerStateValue: UInt16
            (powerStateValue, duration) = try ByteUtils.decode(bytes: payload, UInt16.self, UInt32.self)
            
            guard let powerState = LIFXDevice.PowerState(rawValue: powerStateValue) else {
                throw LIFXMessageParsingError("Invalid power state")
            }
            self.powerState = powerState
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: powerState.rawValue, value2: duration)
        }
    }
}
