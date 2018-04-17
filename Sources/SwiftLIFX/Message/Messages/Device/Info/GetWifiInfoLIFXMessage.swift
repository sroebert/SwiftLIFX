import Foundation

extension LIFXMessages {
    public struct GetWifiInfo: LIFXMessage {
        
        // MARK: - Init
        
        public init() {
            
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 16
        
        public init(payload: [UInt8]) throws {
            
        }
    }
}
