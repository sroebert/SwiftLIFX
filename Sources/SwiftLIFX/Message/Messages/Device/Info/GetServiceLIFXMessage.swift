import Foundation

extension LIFXMessages {
    public struct GetService: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 2
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
