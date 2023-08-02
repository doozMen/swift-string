import Foundation

extension String {

  public func indentNonEmpty(_ kind: IndentKind, omittingEmptySubsequences: Bool = false) -> String {
    let lines = split(separator: "\n", omittingEmptySubsequences: omittingEmptySubsequences)
    return lines.indentNonEmpty(kind)
  }

  public var utf8: Data {
    get throws {
      guard let data = data(using: .utf8) else {
        throw Error.invalidUtf8Data()
      }
      return data
    }
  }

  public enum Error: Swift.Error {
    case invalidUtf8Data(file: String = #fileID, function: String = #function, line: UInt = #line)
  }

  public func capitalizingFirstLetter() -> String {
    prefix(1).capitalized + dropFirst()
  }

  public mutating func capitalizeFirstLetter() {
    self = capitalizingFirstLetter()
  }

  public func lowercasedFirstCharacter() -> String {
    guard !isEmpty else { return self }

    let capitalizedFirstCharacter = self[startIndex].lowercased()
    let result = capitalizedFirstCharacter + dropFirst()

    return result
  }

  public func camelCase(to kind: KebabSnake) -> String {
    let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
    let normalPattern = "([a-z0-9])([A-Z])"
    return processCamelCaseRegex(pattern: acronymPattern, separator: kind.rawValue)?
      .processCamelCaseRegex(pattern: normalPattern, separator: kind.rawValue)?.lowercased() ?? lowercased()
  }

  public enum KebabSnake: String {
    case kebab = "-"
    case snake = "_"
  }

  public func camelCase() -> String {
    let words = self.components(separatedBy: CharacterSet(charactersIn: "-_"))
    let firstWord = words.first ?? ""
    let capitalizedWords = words.dropFirst().map { $0.capitalized }
    let camelCaseString = [firstWord] + capitalizedWords
    return camelCaseString.joined()
  }

  // MARK: Private

  private func processCamelCaseRegex(pattern: String, separator: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1\(separator)$2")
  }
}

extension String {
  public func trimmingLines() -> String {
    split(separator: "\n", omittingEmptySubsequences: false)
      .map { $0.trimmed() }
      .joined(separator: "\n")
  }
}

extension Substring {
  func trimmed() -> Substring {
    guard let i = lastIndex(where: { $0 != " " }) else {
      return ""
    }
    return self[...i]
  }
}

public enum IndentKind {
  case tabs(Int)
  case spaces(Int, tabs: Int)

  var indentation: String {
    switch self {
      case .spaces(let spaces, tabs: let tabs):
        return String(repeating: String(repeating: " ", count: spaces), count: tabs)
      case .tabs(let tabs):
        return String(repeating: "\t", count: tabs)
    }
  }
}

extension Array where Element == Substring {
  public func indentNonEmpty(_ kind: IndentKind) -> String {
    let indentedLines = map { !$0.isEmpty ? "\(kind.indentation)\($0)" : $0 }
    return indentedLines.joined(separator: "\n")
  }
}

extension Array where Element == String {
  public func indentNonEmpty(_ kind: IndentKind) -> String {
    let indentedLines = map { !$0.isEmpty ? "\(kind.indentation)\($0)" : $0 }
    return indentedLines.joined(separator: "\n")
  }
}
