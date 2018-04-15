import Foundation

struct GetWifiFirmwareLIFXMessage: LIFXMessage {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 18
    
    init(payload: [UInt8]) throws {
        
    }
}
