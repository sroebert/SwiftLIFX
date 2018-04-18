import Foundation

protocol ByteCodable {
    static var lifxByteCount: Int { get }
    init(lifxBytes: [UInt8]) throws
    func encodeForLIFX() -> [UInt8]
}

extension String: ByteCodable {
    static let lifxByteCount = 32
    
    init(lifxBytes: [UInt8]) throws {
        var lifxBytes = lifxBytes
        if lifxBytes.last != 0 {
            lifxBytes.append(0)
        }
        self.init(cString: &lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        guard var cStringValue = cString(using: .utf8), !cStringValue.isEmpty else {
            return []
        }
        
        _ = cStringValue.removeLast()
        var bytes = cStringValue.map { UInt8($0) }
        if bytes.count > String.lifxByteCount {
            bytes.removeLast(bytes.count - String.lifxByteCount)
        } else if bytes.count < String.lifxByteCount {
            bytes.append(contentsOf: Array(repeating: 0, count: String.lifxByteCount - bytes.count))
        }
        return bytes
    }
}

extension UInt8: ByteCodable {
    static let lifxByteCount = MemoryLayout<UInt8>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToValue(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.valueToBytes(self)
    }
}

extension UInt16: ByteCodable {
    static let lifxByteCount = MemoryLayout<UInt16>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToValue(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.valueToBytes(self)
    }
}

extension Int16: ByteCodable {
    static let lifxByteCount = MemoryLayout<Int16>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToValue(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.valueToBytes(self)
    }
}

extension UInt32: ByteCodable {
    static let lifxByteCount = MemoryLayout<UInt32>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToValue(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.valueToBytes(self)
    }
}

extension UInt64: ByteCodable {
    static let lifxByteCount = MemoryLayout<UInt64>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToValue(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.valueToBytes(self)
    }
}

extension Float32: ByteCodable {
    static let lifxByteCount = MemoryLayout<Float32>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToValue(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.valueToBytes(self)
    }
}

extension LIFXDevice.Service: ByteCodable {
    static let lifxByteCount = MemoryLayout<LIFXDevice.Service.RawValue>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToRawRepresentable(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.rawRepresentableToBytes(self)
    }
}

extension LIFXDevice.Firmware: ByteCodable {
    static let lifxByteCount =
        MemoryLayout<UInt64>.size +
        MemoryLayout<UInt64>.size +
        MemoryLayout<UInt32>.size

    init(lifxBytes: [UInt8]) throws {
        (build, reserved, version) = try ByteUtils.decode(lifxBytes)
    }

    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.encode(build, reserved, version)
    }
}

extension LIFXDevice.Version: ByteCodable {
    static let lifxByteCount =
        MemoryLayout<UInt32>.size +
        MemoryLayout<UInt32>.size +
        MemoryLayout<UInt32>.size

    init(lifxBytes: [UInt8]) throws {
        (vendor, product, hardwareVersion) = try ByteUtils.decode(lifxBytes)
    }

    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.encode(vendor, product, hardwareVersion)
    }
}

extension LIFXDevice.PowerState: ByteCodable {
    static let lifxByteCount = MemoryLayout<LIFXDevice.PowerState.RawValue>.size
    
    init(lifxBytes: [UInt8]) throws {
        self = try ByteUtils.bytesToRawRepresentable(lifxBytes)
    }
    
    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.rawRepresentableToBytes(self)
    }
}

extension LIFXLight.Color: ByteCodable {
    static let lifxByteCount =
        MemoryLayout<UInt16>.size +
        MemoryLayout<UInt16>.size +
        MemoryLayout<UInt16>.size +
        MemoryLayout<UInt16>.size

    init(lifxBytes: [UInt8]) throws {
        (hue, saturation, brightness, kelvin) = try ByteUtils.decode(lifxBytes)
    }

    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.encode(hue, saturation, brightness, kelvin)
    }
}

extension LIFXLight.State: ByteCodable {
    static let lifxByteCount =
        LIFXLight.Color.lifxByteCount +
        MemoryLayout<Int16>.size +
        LIFXDevice.PowerState.lifxByteCount +
        String.lifxByteCount +
        MemoryLayout<UInt64>.size

    init(lifxBytes: [UInt8]) throws {
        (color, reserved1, powerState, label, reserved2) = try ByteUtils.decode(lifxBytes)
    }

    func encodeForLIFX() -> [UInt8] {
        return ByteUtils.encode(color, reserved1, powerState, label, reserved2)
    }
}
