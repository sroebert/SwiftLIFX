import Foundation

struct StateHostInfoLIFXMessage: LIFXMessage {
    
    // MARK: - Properties
    
    var signal: Float32
    var tx: UInt32
    var rx: UInt32
    
    // MARK: - Init
    
    init(signal: Float32 = 0, tx: UInt32 = 0, rx: UInt32 = 0) {
        self.signal = signal
        self.tx = tx
        self.rx = rx
    }
    
    // MARK: - LIFXMessage
    
    static let id: UInt16 = 13
    
    init(payload: [UInt8]) throws {
        (signal, tx, rx) = try ByteUtils.decode(bytes: payload, Float32.self, UInt32.self, UInt32.self)
    }
    
    func encode() -> [UInt8] {
        return ByteUtils.encode(value1: signal, value2: tx, value3: rx, value4: Int16(0))
    }
}
