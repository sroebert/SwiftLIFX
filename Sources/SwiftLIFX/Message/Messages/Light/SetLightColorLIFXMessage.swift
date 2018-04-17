import Foundation

extension LIFXMessages {
    public struct SetLightColor: LIFXMessage {
        
        // MARK: - Properties
        
        public var color: LIFXLight.Color
        public var duration: UInt32
        
        // MARK: - Init
        
        public init(color: LIFXLight.Color, duration: UInt32 = 0) {
            self.color = color
            self.duration = duration
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 102
        
        public init(payload: [UInt8]) throws {
            var offset = 1
            
            color = try LIFXLight.Color(bytes: payload, offset: offset)
            offset += LIFXLight.Color.size
            
            duration = try ByteUtils.bytesToValue(offset: offset, bytes: payload, type: UInt32.self)
        }
        
        public func encode() -> [UInt8] {
            return [
                [0],
                color.encode(),
                ByteUtils.valueToByteArray(duration),
            ].flatMap { $0 }
        }
    }
}
