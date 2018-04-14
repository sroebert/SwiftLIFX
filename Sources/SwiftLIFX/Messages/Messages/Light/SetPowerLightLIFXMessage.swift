import Foundation

struct SetPowerLightLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var powerState: LIFXDevice.PowerState
    var duration: UInt32
    
    // MARK: - Init
    
    init(powerState: LIFXDevice.PowerState, duration: UInt32 = 0) {
        self.powerState = powerState
        self.duration = duration
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 117
    
    init(payload: [UInt8]) throws {
        let powerStateValue: UInt16
        (powerStateValue, duration) = try ByteUtils.decode(bytes: payload, UInt16.self, UInt32.self)
        
        guard let powerState = LIFXDevice.PowerState(rawValue: powerStateValue) else {
            throw LIFXMessageParsingError("Invalid power state")
        }
        self.powerState = powerState
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: powerState.rawValue, value2: duration)
    }
}
