import Foundation

extension LIFXMessages {
    public struct GetInfo: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 34
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
