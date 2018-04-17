import Foundation

extension LIFXMessages {
    public struct GetPower: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 20
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
