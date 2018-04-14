import Foundation
import NIO

public class LIFXDevice: Hashable, Equatable {
    
    // MARK: - Types
    
    enum Service: UInt8 {
        case UDP = 1
    }
    
    public enum PowerState: UInt16 {
        case on = 65535
        case off = 0
        
        var toggled: PowerState {
            switch self {
            case .on: return .off
            case .off: return .on
            }
        }
    }
    
    // MARK: - Properties
    
    public let macAddress: MacAddress
    public let socketAddress: SocketAddress?
    
    // MARK: - Init
    
    public init(macAddress: MacAddress, socketAddress: SocketAddress? = nil) {
        self.macAddress = macAddress
        self.socketAddress = socketAddress
    }
    
    // MARK: - Hashable
    
    public var hashValue: Int {
        return macAddress.hashValue
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: LIFXDevice, rhs: LIFXDevice) -> Bool {
        return lhs.macAddress == rhs.macAddress
    }
}
