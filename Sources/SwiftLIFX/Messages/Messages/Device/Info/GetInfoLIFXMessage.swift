import Foundation

struct GetInfoLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 34
    
    init(payload: [UInt8]) throws {
        
    }
}
