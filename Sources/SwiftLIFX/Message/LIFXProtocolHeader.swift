import Foundation

public struct LIFXProtocolHeader {
    
    // MARK: - Constants
    
    private struct OriginTaggedAddressableProtocol {
        private static let taggedValue: UInt16 = 0b0011010000000000
        private static let notTaggedValue: UInt16 = 0b0001010000000000
        
        static func isTagged(_ value: UInt16) -> Bool {
            return (value & 0b0000010000000000) == 0b0000010000000000
        }
        
        static func value(isTagged: Bool) -> UInt16 {
            if isTagged {
                return taggedValue
            } else {
                return notTaggedValue
            }
        }
    }
    
    private struct ReservedAckResponse {
        private static let acknowledgementRequiredValue: UInt8 = 0b00000010
        private static let responseRequiredValue: UInt8 = 0b00000001
        
        static func isAcknowledgementRequired(_ value: UInt8) -> Bool {
            return (value & acknowledgementRequiredValue) == acknowledgementRequiredValue
        }
        
        static func isResponseRequired(_ value: UInt8) -> Bool {
            return (value & responseRequiredValue) == responseRequiredValue
        }
        
        static func value(isAcknowledgementRequired: Bool, isResponseRequired: Bool) -> UInt8 {
            var value: UInt8 = 0
            if isAcknowledgementRequired {
                value |= acknowledgementRequiredValue
            }
            if isResponseRequired {
                value |= responseRequiredValue
            }
            return value
        }
    }
    
    public static let size = 36
    
    // MARK: - Frame Properties
    
    public var size: Int = 0
    public var isTagged: Bool = true
    public var source: UInt32 = 0
    
    // MARK: - Frame Address Properties
    
    public var target: MacAddress?
    public var isAcknowledgementRequired: Bool = false
    public var isResponseRequired: Bool = false
    public var sequence: UInt8 = 0
    
    // MARK: - Protocol Header Properties
    
    public let type: UInt16
    
    // MARK: - Init

    public init(messageType: LIFXMessage.Type) {
        self.type = messageType.id
    }
    
    public init(for message: LIFXMessage) {
        self.init(messageType: Swift.type(of: message))
    }

    init(bytes: [UInt8]) throws {
        var offset = 0
        
        let sizeValue = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt16.self)
        size = Int(sizeValue)
        offset += MemoryLayout.size(ofValue: sizeValue)
        
        let originTaggedAddressableProtocol = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt16.self)
        isTagged = OriginTaggedAddressableProtocol.isTagged(originTaggedAddressableProtocol)
        offset += MemoryLayout.size(ofValue: originTaggedAddressableProtocol)
        
        source = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt32.self)
        offset += MemoryLayout.size(ofValue: source)
        
        let targetValue = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt64.self)
        if targetValue != 0 {
            target = MacAddress(intValue: targetValue)
        } else {
            target = nil
        }
        offset += MemoryLayout<UInt64>.size
        
        offset += 6 // Reserved
        let reservedAckResponse = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt8.self)
        isAcknowledgementRequired = ReservedAckResponse.isAcknowledgementRequired(reservedAckResponse)
        isResponseRequired = ReservedAckResponse.isResponseRequired(reservedAckResponse)
        offset += MemoryLayout.size(ofValue: reservedAckResponse)
        
        sequence = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt8.self)
        offset += MemoryLayout.size(ofValue: sequence)
        
        offset += 8 // Reserved
        type = try ByteUtils.bytesToValue(offset: offset, bytes: bytes, type: UInt16.self)
    }

    func encode() -> [UInt8] {
        let targetValue: UInt64 = target?.intValue ?? 0
        return [
            // Frame
            ByteUtils.valueToByteArray(UInt16(size)),
            ByteUtils.valueToByteArray(OriginTaggedAddressableProtocol.value(
                isTagged: isTagged
            )),
            ByteUtils.valueToByteArray(source),
            // Frame Address
            ByteUtils.valueToByteArray(targetValue),
            [0, 0, 0, 0, 0, 0], // Reserved
            ByteUtils.valueToByteArray(ReservedAckResponse.value(
                isAcknowledgementRequired: isAcknowledgementRequired,
                isResponseRequired: isResponseRequired
            )),
            ByteUtils.valueToByteArray(sequence),
            // Protocol Header
            [0, 0, 0, 0, 0, 0, 0, 0], // Reserved
            ByteUtils.valueToByteArray(type),
            [0, 0], // Reserved
        ].flatMap { $0 }
    }
}
