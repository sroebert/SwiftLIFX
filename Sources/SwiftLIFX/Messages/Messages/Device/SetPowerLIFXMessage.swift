import Foundation

struct SetPowerLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var powerState: LIFXDevice.PowerState
    
    // MARK: - Init
    
    init(powerState: LIFXDevice.PowerState) {
        self.powerState = powerState
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 21
    
    init(payload: [UInt8]) throws {
        let powerStateValue = try ByteUtils.decode(bytes: payload, UInt16.self)
        
        guard let powerState = LIFXDevice.PowerState(rawValue: powerStateValue) else {
            throw LIFXMessageParsingError("Invalid power state")
        }
        self.powerState = powerState
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: powerState.rawValue)
    }
}
