//
//  MacAddress.swift
//  App
//
//  Created by Steven Roebert on 12/04/2018.
//

import Foundation

public struct MacAddress: Equatable, Hashable, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var address: [UInt8]
    
    // MARK: - Init
    
    public init?(address: [UInt8]) {
        guard address.count == 6 else {
            return nil
        }
        self.address = address
    }
    
    public init?(string: String) {
        let hexPairs = string.split(separator: ":")
        let address = hexPairs.compactMap { hexPair -> UInt8? in
            guard let cString = hexPair.cString(using: .utf8), cString.count == 3 else {
                return nil
            }
            return UInt8(strtoul(cString, nil, 16))
        }
        self.init(address: address)
    }
    
    public init?(intValue: UInt64) {
        let address = stride(from: 0, to: 48, by: 8).map {
            UInt8(truncatingIfNeeded: intValue >> UInt64($0))
        }
        self.init(address: address)
    }
    
    // MARK: - Parsing
    
    public var string: String {
        return address
            .map { $0.lowercaseHexPair }
            .joined(separator: ":")
    }
    
    public var intValue: UInt64 {
        return address.reversed().reduce(0) { total, value in
            return total << 8 + UInt64(value)
        }
    }
    
    // MARK: - Hashable
    
    public var hashValue: Int {
        return string.hashValue
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: MacAddress, rhs: MacAddress) -> Bool {
        return lhs.address == rhs.address
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        return address.map { String(format: "%02hhX", $0) }.joined(separator: ":")
    }
}

extension UInt8 {
    fileprivate var lowercaseHexPair: String {
        let hexString = String(self, radix: 16, uppercase: false)
        return String(repeating: "0", count: 2 - hexString.count) + hexString
    }
}
