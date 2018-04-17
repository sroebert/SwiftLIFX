import Foundation

struct LIFXMessageParsingError: LocalizedError {
    let errorDescription: String?
    
    init(_ errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
}
