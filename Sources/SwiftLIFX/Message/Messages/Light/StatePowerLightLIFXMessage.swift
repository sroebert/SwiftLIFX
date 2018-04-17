import Foundation

extension LIFXMessages {
    public struct StatePowerLight: LIFXMessage {
        
        // MARK: - Properties
        
        public var powerState: LIFXDevice.PowerState
        
        // MARK: - Init
        
        public init(powerState: LIFXDevice.PowerState) {
            self.powerState = powerState
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 118
        
        public init(payload: [UInt8]) throws {
            let powerStateValue = try ByteUtils.decode(bytes: payload, UInt16.self)
            guard let powerState = LIFXDevice.PowerState(rawValue: powerStateValue) else {
                throw LIFXMessageParsingError("Invalid power state")
            }
            self.powerState = powerState
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: powerState.rawValue)
        }
    }
}
