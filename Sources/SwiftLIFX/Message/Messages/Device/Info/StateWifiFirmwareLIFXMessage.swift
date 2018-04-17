import Foundation

struct StateWifiFirmwareLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var firmware: LIFXDevice.Firmware
    
    // MARK: - Init
    
    init(firmware: LIFXDevice.Firmware) {
        self.firmware = firmware
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 19
    
    init(payload: [UInt8]) throws {
        let (build, _, version) = try ByteUtils.decode(bytes: payload, UInt64.self, UInt64.self, UInt32.self)
        firmware = LIFXDevice.Firmware(build: build, version: version)
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: firmware.build, value2: UInt64(0), value3: firmware.version)
    }
}
