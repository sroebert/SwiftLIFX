import Foundation

extension LIFXMessages {
    public struct SetLabel: LIFXMessage {
        
        // MARK: - Properties
        
        public var label: String
        
        // MARK: - Init
        
        public init(label: String) {
            self.label = label
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 24
        
        public init(payload: [UInt8]) throws {
            label = try ByteUtils.bytesToString(offset: 0, bytes: payload, count: 32)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.stringToByteArray(label, length: 32)
        }
    }
}
