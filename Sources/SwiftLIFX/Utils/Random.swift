import Foundation
#if os(Linux)
import Glibc
#endif

struct Random {
    
    // MARK: - Initialize
    
    #if os(Linux)
    private static let seedRandom: Void = {
        let current = Date().timeIntervalSinceReferenceDate
        let salt = current.truncatingRemainder(dividingBy: 1) * 100000000
        Glibc.srand(UInt32(current + salt))
    }()
    #endif

    // MARK: - Create
    
    static func bytes(ofLength length: Int) -> [UInt8] {
        return (0..<length).map { _ in
            UInt8(integer(min: 0, max: Int(UInt8.max)))
        }
    }

    static func integer(min: Int, max: Int) -> Int {
        let top = max - min + 1
        #if os(Linux)
            _ = seedRandom
            return Int(Glibc.random() % top) + min
        #else
            return Int(arc4random_uniform(UInt32(top))) + min
        #endif
    }
}
