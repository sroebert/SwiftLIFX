import Foundation

struct GetPowerLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 20
    
    init(payload: [UInt8]) throws {
        
    }
}
