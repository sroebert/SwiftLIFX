import Foundation

extension LIFXMessages {
    public struct StateInfo: LIFXMessage {
        
        // MARK: - Properties
        
        public var time: UInt64
        public var uptime: UInt64
        public var downtime: UInt64
        
        // MARK: - Init
        
        public init(time: UInt64, uptime: UInt64, downtime: UInt64) {
            self.time = time
            self.uptime = uptime
            self.downtime = downtime
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 35
        
        public init(payload: [UInt8]) throws {
            (time, uptime, downtime) = try ByteUtils.decode(bytes: payload, UInt64.self, UInt64.self, UInt64.self)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: time, value2: uptime, value3: downtime)
        }
    }
}
