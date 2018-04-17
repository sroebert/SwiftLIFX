import Foundation

struct GetLightStateLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 101
    
    init(payload: [UInt8]) throws {
        
    }
}
