import Foundation


public extension Data {
  public var utf8String: String {
    get throws {
      guard let string = String(data: self, encoding: .utf8) else {
        throw Error.invalid()
      }
      return string
    }
  }
  public enum Error: Swift.Error {
    case invalid(file: String = #fileID, function: String = #function, line: UInt = #line)
  }
}
