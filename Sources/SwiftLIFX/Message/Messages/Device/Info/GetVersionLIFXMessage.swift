import Foundation

struct GetVersionLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 32
    
    init(payload: [UInt8]) throws {
        
    }
}
