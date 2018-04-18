import Foundation

public protocol LIFXMessage {
    init(payload: [UInt8]) throws
    func encode() -> [UInt8]
}

extension LIFXMessage {
    public func encode() -> [UInt8] {
        return []
    }
}

public class EmptyPayloadLIFXMessage: LIFXMessage {
    public required init() {
        
    }
    
    public required init(payload: [UInt8]) throws {
        
    }
    
    public func encode() -> [UInt8] {
        return []
    }
}
