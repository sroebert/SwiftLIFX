import Foundation

extension LIFXMessages {
    public struct GetLabel: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 23
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
