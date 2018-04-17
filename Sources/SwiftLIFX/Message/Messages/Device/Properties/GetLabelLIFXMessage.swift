import Foundation

struct GetLabelLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 23
    
    init(payload: [UInt8]) throws {
        
    }
}
