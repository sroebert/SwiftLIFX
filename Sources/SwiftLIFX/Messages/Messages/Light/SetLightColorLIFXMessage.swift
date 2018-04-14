import Foundation

struct SetLightColorLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var color: LIFXLight.Color
    var duration: UInt32
    
    // MARK: - Init
    
    init(color: LIFXLight.Color, duration: UInt32 = 0) {
        self.color = color
        self.duration = duration
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 102
    
    init(payload: [UInt8]) throws {
        var offset = 1
        
        color = try LIFXLight.Color(bytes: payload, offset: offset)
        offset += LIFXLight.Color.size
        
        duration = try ByteUtils.bytesToValue(offset: offset, bytes: payload, type: UInt32.self)
    }
    
    func encode() -> [UInt8] {
        return [
            [0],
            color.encode(),
            ByteUtils.valueToByteArray(duration),
        ].flatMap { $0 }
    }
}
