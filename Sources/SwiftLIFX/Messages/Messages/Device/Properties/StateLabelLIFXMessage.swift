import Foundation

struct StateLabelLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var label: String
    
    // MARK: - Init
    
    init(label: String) {
        self.label = label
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 25
    
    init(payload: [UInt8]) throws {
        label = try ByteUtils.bytesToString(offset: 0, bytes: payload, count: 32)
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.stringToByteArray(label, length: 32)
    }
}
