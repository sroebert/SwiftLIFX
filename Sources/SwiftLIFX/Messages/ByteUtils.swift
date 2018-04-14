import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct ByteUtils {
    
    // MARK: - Core
    
    static let isLittleEndian: Bool = {
        let number: UInt16 = 0x1234
        let converted = number.littleEndian
        return number == converted
    }()
    
    static func valueToByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        
        var array = withUnsafeBytes(of: &value) { Array($0) }
        if !isLittleEndian {
            array.reverse()
        }
        return array
    }
    
    static func bytesToValue<Value>(offset: Int, bytes: [UInt8], type: Value.Type) throws -> Value {
        let size = MemoryLayout<Value>.size
        guard offset + size <= bytes.count else {
            throw LIFXMessageParsingError("Bytes are too short.")
        }
        
        var bytes = Array(bytes[offset..<(offset + size)])
        if !isLittleEndian {
            bytes.reverse()
        }
        
        return UnsafePointer(bytes).withMemoryRebound(to: Value.self, capacity: 1) {
            $0.pointee
        }
    }
    
    static func bytesToString(offset: Int, bytes: [UInt8], count: Int) throws -> String {
        guard offset + count <= bytes.count else {
            throw LIFXMessageParsingError("Bytes are too short.")
        }
        
        var bytes = Array(bytes[offset..<(offset + count)])
        bytes.append(0)
        return String(cString: &bytes)
    }
    
    // MARK: - Encode
    
    static func encode<Value1>(value1: Value1) -> [UInt8] {
        return valueToByteArray(value1)
    }
    
    static func encode<Value1, Value2>(value1: Value1, value2: Value2) -> [UInt8] {
        return [
            valueToByteArray(value1),
            valueToByteArray(value2),
        ].flatMap { $0 }
    }
    
    static func encode<Value1, Value2, Value3>(value1: Value1, value2: Value2, value3: Value3) -> [UInt8] {
        return [
            valueToByteArray(value1),
            valueToByteArray(value2),
            valueToByteArray(value3),
        ].flatMap { $0 }
    }
    
    static func encode<Value1, Value2, Value3, Value4>(value1: Value1, value2: Value2, value3: Value3, value4: Value4) -> [UInt8] {
        return [
            valueToByteArray(value1),
            valueToByteArray(value2),
            valueToByteArray(value3),
            valueToByteArray(value4),
        ].flatMap { $0 }
    }
    
    static func encode<Value1, Value2, Value3, Value4, Value5>(value1: Value1, value2: Value2, value3: Value3, value4: Value4, value5: Value5) -> [UInt8] {
        return [
            valueToByteArray(value1),
            valueToByteArray(value2),
            valueToByteArray(value3),
            valueToByteArray(value4),
            valueToByteArray(value5),
        ].flatMap { $0 }
    }
    
    // MARK: - Decode
    
    static func decode<Value1>(bytes: [UInt8], _ type1: Value1.Type) throws -> Value1 {
        return try bytesToValue(offset: 0, bytes: bytes, type: type1)
    }
    
    static func decode<Value1, Value2>(bytes: [UInt8], _ type1: Value1.Type, _ type2: Value2.Type) throws -> (Value1, Value2) {
        let size1 = MemoryLayout<Value1>.size
        return try (
            bytesToValue(offset: 0, bytes: bytes, type: type1),
            bytesToValue(offset: size1, bytes: bytes, type: type2)
        )
    }
    
    static func decode<Value1, Value2, Value3>(bytes: [UInt8], _ type1: Value1.Type, _ type2: Value2.Type, _ type3: Value3.Type) throws -> (Value1, Value2, Value3) {
        let size1 = MemoryLayout<Value1>.size
        let size2 = MemoryLayout<Value2>.size
        return try (
            bytesToValue(offset: 0, bytes: bytes, type: type1),
            bytesToValue(offset: size1, bytes: bytes, type: type2),
            bytesToValue(offset: size1 + size2, bytes: bytes, type: type3)
        )
    }
    
    static func decode<Value1, Value2, Value3, Value4>(bytes: [UInt8], _ type1: Value1.Type, _ type2: Value2.Type, _ type3: Value3.Type, _ type4: Value4.Type) throws -> (Value1, Value2, Value3, Value4) {
        let size1 = MemoryLayout<Value1>.size
        let size2 = MemoryLayout<Value2>.size
        let size3 = MemoryLayout<Value3>.size
        return try (
            bytesToValue(offset: 0, bytes: bytes, type: type1),
            bytesToValue(offset: size1, bytes: bytes, type: type2),
            bytesToValue(offset: size1 + size2, bytes: bytes, type: type3),
            bytesToValue(offset: size1 + size2 + size3, bytes: bytes, type: type4)
        )
    }
    
    static func decode<Value1, Value2, Value3, Value4, Value5>(bytes: [UInt8], _ type1: Value1.Type, _ type2: Value2.Type, _ type3: Value3.Type, _ type4: Value4.Type, _ type5: Value5.Type) throws -> (Value1, Value2, Value3, Value4, Value5) {
        let size1 = MemoryLayout<Value1>.size
        let size2 = MemoryLayout<Value2>.size
        let size3 = MemoryLayout<Value3>.size
        let size4 = MemoryLayout<Value4>.size
        return try (
            bytesToValue(offset: 0, bytes: bytes, type: type1),
            bytesToValue(offset: size1, bytes: bytes, type: type2),
            bytesToValue(offset: size1 + size2, bytes: bytes, type: type3),
            bytesToValue(offset: size1 + size2 + size3, bytes: bytes, type: type4),
            bytesToValue(offset: size1 + size2 + size3 + size4, bytes: bytes, type: type5)
        )
    }
}
