import Foundation

extension LIFXMessages {
    public struct GetLightState: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 101
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
