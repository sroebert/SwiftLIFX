import Foundation

struct StateInfoLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var time: UInt64
    var uptime: UInt64
    var downtime: UInt64
    
    // MARK: - Init
    
    init(time: UInt64, uptime: UInt64, downtime: UInt64) {
        self.time = time
        self.uptime = uptime
        self.downtime = downtime
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 35
    
    init(payload: [UInt8]) throws {
        (time, uptime, downtime) = try ByteUtils.decode(bytes: payload, UInt64.self, UInt64.self, UInt64.self)
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: time, value2: uptime, value3: downtime)
    }
}
