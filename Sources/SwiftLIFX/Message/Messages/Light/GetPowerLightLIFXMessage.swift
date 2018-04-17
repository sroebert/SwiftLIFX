import Foundation

extension LIFXMessages {
    public struct GetPowerLight: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 116
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
