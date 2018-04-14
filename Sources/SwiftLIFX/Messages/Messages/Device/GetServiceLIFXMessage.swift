import Foundation

struct GetServiceLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 2
    
    init(payload: [UInt8]) throws {
        
    }
}
