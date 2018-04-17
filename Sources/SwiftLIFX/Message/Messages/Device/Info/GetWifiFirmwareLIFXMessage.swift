import Foundation

extension LIFXMessages {
    public struct GetWifiFirmware: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 18
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
