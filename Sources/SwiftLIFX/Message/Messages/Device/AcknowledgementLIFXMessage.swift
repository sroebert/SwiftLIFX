import Foundation

extension LIFXMessages {
    public struct Acknowledgement: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 45
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
