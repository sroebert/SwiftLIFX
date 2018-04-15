import Foundation

struct GetHostInfoLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 12
    
    init(payload: [UInt8]) throws {
        
    }
}
