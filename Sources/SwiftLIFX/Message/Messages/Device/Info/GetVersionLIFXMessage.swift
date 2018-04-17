import Foundation

extension LIFXMessages {
    public struct GetVersion: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 32
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
