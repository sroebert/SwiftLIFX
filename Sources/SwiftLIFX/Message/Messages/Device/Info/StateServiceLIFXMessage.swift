import Foundation

extension LIFXMessages {
    public struct StateService: LIFXMessage {
        
        // MARK: - Properties
        
        public var service: LIFXDevice.Service
        public var port: UInt32
        
        // MARK: - Init
        
        public init(service: LIFXLight.Service = .UDP, port: UInt32 = UInt32(LIFXConstants.broadcastPort)) {
            self.service = service
            self.port = port
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 3
        
        public init(payload: [UInt8]) throws {
            let serviceValue: UInt8
            (serviceValue, port) = try ByteUtils.decode(bytes: payload, UInt8.self, UInt32.self)
            guard let service = LIFXDevice.Service(rawValue: serviceValue) else {
                throw LIFXMessageParsingError("Invalid service")
            }
            self.service = service
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: service.rawValue, value2: port)
        }
    }
}
