import Foundation

extension LIFXMessages {
    public struct GetHostInfo: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 12
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
