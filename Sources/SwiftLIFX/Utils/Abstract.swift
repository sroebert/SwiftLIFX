import Foundation

/// Internal function to mark methods as abstract, indicating that they have to be overridden in subclasses.
func _abstract(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Method must be overridden", file: file, line: line)
}
