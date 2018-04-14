import Foundation

extension LIFXLight {
    public struct Color {
        
        // MARK: - Constants
        
        static let size = 8
        
        // MARK: - Properties
        
        public var hue: UInt16
        public var saturation: UInt16
        public var brightness: UInt16
        public var kelvin: UInt16
        
        // MARK: - Floats
        
        public var hueDegrees: Int {
            get {
                return Int(round((Float(hue) / Float(UInt16.max)) * 360))
            }
            set {
                hue = UInt16(round((Float(newValue) / 360) * Float(UInt16.max)))
            }
        }
        
        public var saturationPercentage: Float {
            get {
                return Float(saturation) / Float(UInt16.max)
            }
            set {
                saturation = UInt16(newValue * Float(UInt16.max))
            }
        }
        
        public var brightnessPercentage: Float {
            get {
                return Float(brightness) / Float(UInt16.max)
            }
            set {
                brightness = UInt16(newValue * Float(UInt16.max))
            }
        }
        
        // MARK: - Init
        
        public init(hue: UInt16, saturation: UInt16, brightness: UInt16, kelvin: UInt16) {
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
            self.kelvin = kelvin
        }
        
        // MARK: - Encode / Decode
        
        func encode() -> [UInt8] {
            return ByteUtils.encode(value1: hue, value2: saturation, value3: brightness, value4: kelvin)
        }
        
        init(bytes: [UInt8], offset: Int = 0) throws {
            var bytes = bytes
            if offset > 0 {
                guard bytes.count > offset else {
                    throw LIFXMessageParsingError("Bytes to short")
                }
                bytes = Array(bytes[offset...])
            }
            (hue, saturation, brightness, kelvin) = try ByteUtils.decode(bytes: bytes, UInt16.self, UInt16.self, UInt16.self, UInt16.self)
        }
    }
    
    public struct State {
        public var color: Color
        public var powerState: PowerState
        public var label: String
    }
}
