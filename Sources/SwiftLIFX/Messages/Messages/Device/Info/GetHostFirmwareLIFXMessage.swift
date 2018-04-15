import Foundation

struct GetHostFirmwareLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 14
    
    init(payload: [UInt8]) throws {
        
    }
}
