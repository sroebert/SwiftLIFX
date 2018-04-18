import Foundation

public class LIFXLight: LIFXDevice {
    public struct Color: Hashable, Equatable {
        
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
    }
    
    public struct State: Equatable {
        public var color: Color
        let reserved1: Int16
        public var powerState: PowerState
        public var label: String
        let reserved2: UInt64
        
        public init(color: Color, powerState: PowerState, label: String) {
            self.color = color
            reserved1 = 0
            self.powerState = powerState
            self.label = label
            reserved2 = 0
        }
    }
}
