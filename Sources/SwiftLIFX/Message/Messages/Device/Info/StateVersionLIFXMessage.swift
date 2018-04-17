import Foundation

extension LIFXMessages {
    public struct StateVersion: LIFXMessage {
        
        // MARK: - Properties
        
        public var version: LIFXDevice.Version
        
        // MARK: - Init
        
        public init(version: LIFXDevice.Version) {
            self.version = version
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 33
        
        public init(payload: [UInt8]) throws {
            let (vendor, product, hardwareVersion) = try ByteUtils.decode(bytes: payload, UInt32.self, UInt32.self, UInt32.self)
            version = LIFXDevice.Version(vendor: vendor, product: product, hardwareVersion: hardwareVersion)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: version.vendor, value2: version.product, value3: version.hardwareVersion)
        }
    }
}
