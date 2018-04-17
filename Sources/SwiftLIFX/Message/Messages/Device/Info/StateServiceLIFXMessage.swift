import Foundation

struct StateServiceLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var service: LIFXDevice.Service
    var port: UInt32
    
    // MARK: - Init
    
    init(service: LIFXLight.Service = .UDP, port: UInt32 = UInt32(LIFXConstants.broadcastPort)) {
        self.service = service
        self.port = port
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 3
    
    init(payload: [UInt8]) throws {
        let serviceValue: UInt8
        (serviceValue, port) = try ByteUtils.decode(bytes: payload, UInt8.self, UInt32.self)
        guard let service = LIFXDevice.Service(rawValue: serviceValue) else {
            throw LIFXMessageParsingError("Invalid service")
        }
        self.service = service
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: service.rawValue, value2: port)
    }
}
