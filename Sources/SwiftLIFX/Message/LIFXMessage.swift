import Foundation

public protocol LIFXMessage {
    static var id: UInt16 { get }
    
    init(payload: [UInt8]) throws
    
    func encode() -> [UInt8]
}

extension LIFXMessage {
    public func encode() -> [UInt8] {
        return []
    }
    
    public func sendToAll() {
        
    }
    
    public func send(to device: LIFXDevice) {
        
    }
}
