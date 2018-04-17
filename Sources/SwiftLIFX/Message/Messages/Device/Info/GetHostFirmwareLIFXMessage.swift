import Foundation

extension LIFXMessages {
    public struct GetHostFirmware: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 14
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
