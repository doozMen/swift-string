import Foundation
import RegexBuilder

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
  
  public func wordsInCamelCaseOrOneOfTheTransformSeparators() -> [String] {
    let separator =  Regex {
      ChoiceOf{
        One(Transform.kebab.rawValue)
        One(Transform.snake.rawValue)
        One(Transform.dots.rawValue)
      }
    }
    
    let wordsRegex = Regex {
      ChoiceOf{
        One(("A"..."Z"))
        One(("a"..."z"))
        separator
      }
      ZeroOrMore {
        ChoiceOf {
          OneOrMore(("a"..."z"))
          OneOrMore(.digit)
        }
      }
    }
    
    let words = self
      .matches(of: wordsRegex)
      .map {
        $0.description
          .replacingOccurrences(of: Transform.kebab.rawValue, with: "")
          .replacingOccurrences(of: Transform.snake.rawValue, with: "")
          .replacingOccurrences(of: Transform.dots.rawValue, with: "")
      }
    return words.filter { !$0.isEmpty }
  }

  public func camelCase(to kind: Transform) -> String {
    let words = wordsInCamelCaseOrOneOfTheTransformSeparators()
    guard let start = words.first?.lowercased() else {
      return ""
    }
    return words
      .dropFirst()
      .reduce(start) { partialResult, word in
        "\(partialResult)\(kind.rawValue)\(word.lowercased())"
      }
  }

  public enum Transform: String, CaseIterable {
    case kebab = "-"
    case snake = "_"
    case dots = "."
  }

  public func camelCase() -> String {
    let words = wordsInCamelCaseOrOneOfTheTransformSeparators()
    guard let start = words.first?.lowercasedFirstCharacter() else {
      return ""
    }
    return words
      .dropFirst()
      .reduce(start) { partialResult, word in
      "\(partialResult)\(word.capitalizingFirstLetter())"
    }
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

func toCamelCase(inputString: String) -> String {
  let pattern = Regex {
      ZeroOrMore {
        Capture {
          ChoiceOf {
            ("a"..."z")
            ("A"..."Z")
            OneOrMore(.digit)   // Matches a sequence of digits (whole number)
          }
        }
      }
  }

  let matches = inputString.matches(of: pattern).map { $0.output.0 }
  let firstWord = matches.first ?? ""
  return ([String(firstWord)]
          + matches.dropFirst().map { $0.description.capitalizingFirstLetter() }).joined()
}
