import Foundation

struct StateVersionLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var version: LIFXDevice.Version
    
    // MARK: - Init
    
    init(version: LIFXDevice.Version) {
        self.version = version
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 33
    
    init(payload: [UInt8]) throws {
        let (vendor, product, hardwareVersion) = try ByteUtils.decode(bytes: payload, UInt32.self, UInt32.self, UInt32.self)
        version = LIFXDevice.Version(vendor: vendor, product: product, hardwareVersion: hardwareVersion)
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: version.vendor, value2: version.product, value3: version.hardwareVersion)
    }
}
