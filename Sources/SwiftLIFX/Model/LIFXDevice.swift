import Foundation
import NIO

public class LIFXDevice: Hashable, Equatable {
    
    // MARK: - Types
    
    public enum Service: UInt8 {
        case udp = 1
        case reserved1 = 2
        case reserved2 = 3
        case reserved3 = 4
    }
    
    public struct Firmware: Equatable {
        public var build: UInt64
        let reserved: UInt64
        public var version: UInt32
        
        public init(build: UInt64, version: UInt32) {
            self.build = build
            reserved = 0
            self.version = version
        }
    }
    
    public struct Version: Equatable {
        public var vendor: UInt32
        public var product: UInt32
        public var hardwareVersion: UInt32
        
        public init(vendor: UInt32, product: UInt32, hardwareVersion: UInt32) {
            self.vendor = vendor
            self.product = product
            self.hardwareVersion = hardwareVersion
        }
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
