import Foundation

protocol LIFXMessage {
    static var id: UInt16 { get }
    
    init(payload: [UInt8]) throws
    
    func encode() -> [UInt8]
}

extension LIFXMessage {
    func encode() -> [UInt8] {
        return []
    }
    
    func sendToAll() {
        
    }
    
    func send(to device: LIFXDevice) {
        
    }
}
