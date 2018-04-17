import Foundation

extension LIFXMessages {
    public struct StateHostInfo: LIFXMessage {
        
        // MARK: - Properties
        
        public var signal: Float32
        public var tx: UInt32
        public var rx: UInt32
        
        // MARK: - Init
        
        public init(signal: Float32 = 0, tx: UInt32 = 0, rx: UInt32 = 0) {
            self.signal = signal
            self.tx = tx
            self.rx = rx
        }
        
        // MARK: - LIFXMessage
        
        public static let id: UInt16 = 13
        
        public init(payload: [UInt8]) throws {
            (signal, tx, rx) = try ByteUtils.decode(bytes: payload, Float32.self, UInt32.self, UInt32.self)
        }
        
        public func encode() -> [UInt8] {
            return ByteUtils.encode(value1: signal, value2: tx, value3: rx, value4: Int16(0))
        }
    }
}
