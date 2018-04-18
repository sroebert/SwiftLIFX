struct ByteUtils {
    
    // MARK: - Endian
    
    static let isLittleEndian: Bool = {
        let number: UInt16 = 0x1234
        let converted = number.littleEndian
        return number == converted
    }()
    
    // MARK: - Bytes

    static func bytesToValue<Value>(_ bytes: [UInt8]) throws -> Value {
        return try bytesToValue(bytes, offset: 0)
    }
    
    static func bytesToValue<Value>(_ bytes: [UInt8], offset: Int) throws -> Value {
        guard offset < bytes.count && bytes.count - offset >= MemoryLayout<Value>.size else {
            throw LIFXMessageParsingError("Not enough bytes to decode \(Value.self).")
        }
        
        var bytes = bytes
        if !isLittleEndian {
            bytes.reverse()
        }
        return UnsafePointer(bytes).withMemoryRebound(to: Value.self, capacity: 1) {
            $0.advanced(by: offset).pointee
        }
    }
    
    static func valueToBytes<Value>(_ value: Value) -> [UInt8] {
        var value = value
        var array = withUnsafeBytes(of: &value) { Array($0) }
        if !isLittleEndian {
            array.reverse()
        }
        return array
    }
    
    // MARK: - RawRepresentable
    
    static func bytesToRawRepresentable<Value: RawRepresentable>(_ bytes: [UInt8]) throws -> Value {
        let rawValue: Value.RawValue = try bytesToValue(bytes)
        guard let value = Value(rawValue: rawValue) else {
            throw LIFXMessageParsingError("Invalid raw value for \(Value.RawValue.self): \(rawValue).")
        }
        return value
    }
    
    static func rawRepresentableToBytes<Value: RawRepresentable>(_ value: Value) -> [UInt8] {
        return valueToBytes(value.rawValue)
    }
    
    // MARK: - Encode
    
    static func encode<Value1: ByteCodable>(_ value1: Value1) -> [UInt8] {
        return value1.encodeForLIFX()
    }
    
    static func encode<Value1: ByteCodable, Value2: ByteCodable>(_ value1: Value1, _ value2: Value2) -> [UInt8] {
        return [
            value1.encodeForLIFX(),
            value2.encodeForLIFX(),
        ].flatMap { $0 }
    }
    
    static func encode<Value1: ByteCodable, Value2: ByteCodable, Value3: ByteCodable>(_ value1: Value1, _ value2: Value2, _ value3: Value3) -> [UInt8] {
        return [
            value1.encodeForLIFX(),
            value2.encodeForLIFX(),
            value3.encodeForLIFX(),
        ].flatMap { $0 }
    }
    
    static func encode<Value1: ByteCodable, Value2: ByteCodable, Value3: ByteCodable, Value4: ByteCodable>(_ value1: Value1, _ value2: Value2, _ value3: Value3, _ value4: Value4) -> [UInt8] {
        return [
            value1.encodeForLIFX(),
            value2.encodeForLIFX(),
            value3.encodeForLIFX(),
            value4.encodeForLIFX(),
        ].flatMap { $0 }
    }
    
    static func encode<Value1: ByteCodable, Value2: ByteCodable, Value3: ByteCodable, Value4: ByteCodable, Value5: ByteCodable>(_ value1: Value1, _ value2: Value2, _ value3: Value3, _ value4: Value4, _ value5: Value5) -> [UInt8] {
        return [
            value1.encodeForLIFX(),
            value2.encodeForLIFX(),
            value3.encodeForLIFX(),
            value4.encodeForLIFX(),
            value5.encodeForLIFX(),
        ].flatMap { $0 }
    }
    
    // MARK: - Decode
    
    static func decode<Value1: ByteCodable>(_ bytes: [UInt8], offset: Int) throws -> Value1 {
        let bytesForDecoding: [UInt8]
        if offset == 0 {
            bytesForDecoding = bytes
        } else {
            guard offset < bytes.count else {
                throw LIFXMessageParsingError("Not enough bytes to decode \(Value1.self).")
            }
            bytesForDecoding = Array(bytes[offset...])
        }
        return try Value1(lifxBytes: bytesForDecoding)
    }
    
    static func decode<Value1: ByteCodable>(_ bytes: [UInt8]) throws -> Value1 {
        return try decode(bytes, offset: 0)
    }
    
    static func decode<Value1: ByteCodable, Value2: ByteCodable>(_ bytes: [UInt8]) throws -> (Value1, Value2) {
        return (
            try decode(bytes, offset: 0),
            try decode(bytes, offset: Value1.lifxByteCount)
        )
    }
    
    static func decode<Value1: ByteCodable, Value2: ByteCodable, Value3: ByteCodable>(_ bytes: [UInt8]) throws -> (Value1, Value2, Value3) {
        return (
            try decode(bytes, offset: 0),
            try decode(bytes, offset: Value1.lifxByteCount),
            try decode(bytes, offset: Value1.lifxByteCount + Value2.lifxByteCount)
        )
    }
    
    static func decode<Value1: ByteCodable, Value2: ByteCodable, Value3: ByteCodable, Value4: ByteCodable>(_ bytes: [UInt8]) throws -> (Value1, Value2, Value3, Value4) {
        return (
            try decode(bytes, offset: 0),
            try decode(bytes, offset: Value1.lifxByteCount),
            try decode(bytes, offset: Value1.lifxByteCount + Value2.lifxByteCount),
            try decode(bytes, offset: Value1.lifxByteCount + Value2.lifxByteCount + Value3.lifxByteCount)
        )
    }
    
    static func decode<Value1: ByteCodable, Value2: ByteCodable, Value3: ByteCodable, Value4: ByteCodable, Value5: ByteCodable>(_ bytes: [UInt8]) throws -> (Value1, Value2, Value3, Value4, Value5) {
        return (
            try decode(bytes, offset: 0),
            try decode(bytes, offset: Value1.lifxByteCount),
            try decode(bytes, offset: Value1.lifxByteCount + Value2.lifxByteCount),
            try decode(bytes, offset: Value1.lifxByteCount + Value2.lifxByteCount + Value3.lifxByteCount),
            try decode(bytes, offset: Value1.lifxByteCount + Value2.lifxByteCount + Value3.lifxByteCount + Value4.lifxByteCount)
        )
    }
}
