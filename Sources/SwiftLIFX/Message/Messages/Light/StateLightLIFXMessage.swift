import Foundation

extension LIFXMessages {
    public struct StateLight: LIFXMessage {
        
        // MARK: - Properties
        
        public var color: LIFXLight.Color
        public var powerState: LIFXDevice.PowerState
        public var label: String
        
        // MARK: - Init
        
        public init(color: LIFXLight.Color, powerState: LIFXDevice.PowerState, label: String) {
            self.color = color
            self.powerState = powerState
            self.label = label
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 107
        
        public init(payload: [UInt8]) throws {
            var offset = 0
            
            color = try LIFXLight.Color(bytes: payload)
            offset += LIFXLight.Color.size + 2
            
            let powerStateValue = try ByteUtils.bytesToValue(offset: offset, bytes: payload, type: UInt16.self)
            guard let powerState = LIFXDevice.PowerState(rawValue: powerStateValue) else {
                throw LIFXMessageParsingError("Invalid power state")
            }
            self.powerState = powerState
            
            offset += MemoryLayout.size(ofValue: powerStateValue)
            label = try ByteUtils.bytesToString(offset: offset, bytes: payload, count: 32)
        }
        
        public func encode() -> [UInt8] {
            return [
                color.encode(),
                ByteUtils.valueToByteArray(Int16(0)),
                ByteUtils.valueToByteArray(powerState.rawValue),
                ByteUtils.stringToByteArray(label, length: 32),
                ByteUtils.valueToByteArray(UInt64(0)),
            ].flatMap { $0 }
        }
    }
}
