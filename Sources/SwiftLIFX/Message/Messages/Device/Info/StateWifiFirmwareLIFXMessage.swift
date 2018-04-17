import Foundation

extension LIFXMessages {
    public struct StateWifiFirmware: LIFXMessage {
        
        // MARK: - Properties
        
        public var firmware: LIFXDevice.Firmware
        
        // MARK: - Init
        
        public init(firmware: LIFXDevice.Firmware) {
            self.firmware = firmware
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 19
        
        public init(payload: [UInt8]) throws {
            let (build, _, version) = try ByteUtils.decode(bytes: payload, UInt64.self, UInt64.self, UInt32.self)
            firmware = LIFXDevice.Firmware(build: build, version: version)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: firmware.build, value2: UInt64(0), value3: firmware.version)
        }
    }
}
