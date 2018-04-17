import Foundation

struct AcknowledgementLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 45
    
    init(payload: [UInt8]) throws {
        
    }
}
