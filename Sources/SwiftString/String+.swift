import Foundation
#if canImport(RegexBuilder)
import RegexBuilder
#endif

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
  
  public func splitWordsDigits() -> [String] {
    if #available(iOS 16, *) {
      let splitWordDigits = Regex {
        ChoiceOf {
          ChoiceOf{
            OneOrMore("a"..."z")
            OneOrMore("A"..."z")
          }
          OneOrMore(.digit)
        }
      }
      return self
        .matches(of: splitWordDigits)
        .map {
          $0.description
        }
    } else {
      let pattern = "[a-zA-Z]+|\\d+"
      do {
        let regex = try NSRegularExpression(pattern: pattern)
        let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return results.map {
          String(self[Range($0.range, in: self)!])
        }
      } catch {
        print("Invalid regex: \(error.localizedDescription)")
        return []
      }
    }
  }
  
  public func splitWithoutCamelCase() -> [String]? {
    Transform.allCases.compactMap {
      let components = components(separatedBy: $0.rawValue)
      guard components.count > 1 else {
        return nil
      }
      return components
    }.first
  }
  
  public func wordsInCamelCaseOrOneOfTheTransformSeparators() -> [String] {
    let subject: String
    if self.uppercased() == self {
      subject = self.lowercased()
    } else if let components = self.splitWithoutCamelCase() {
      subject = components.reduce("", { partialResult, next in
        if next.uppercased() == next {
          return "\(partialResult)\(Transform.dots.rawValue)\(next.lowercased())"
        } else {
          return "\(partialResult)\(Transform.dots.rawValue)\(next)"
        }
      })
    } else {
      subject = self
    }
    if #available(iOS 16, *) {
      // Implementation using RegexBuilder
      let separator = Regex {
        ChoiceOf {
          One(Transform.kebab.rawValue)
          One(Transform.snake.rawValue)
          One(Transform.dots.rawValue)
        }
      }
      let wordsRegex = Regex {
        ChoiceOf {
          One(CharacterClass("A"..."Z"))
          One(CharacterClass("a"..."z"))
          separator
        }
        ZeroOrMore {
          ChoiceOf {
            OneOrMore(CharacterClass("a"..."z"))
            OneOrMore(.digit)
          }
        }
      }
      return subject.matches(of: wordsRegex)
        .map { match in
          match.description
            .replacingOccurrences(of: Transform.kebab.rawValue, with: "")
            .replacingOccurrences(of: Transform.snake.rawValue, with: "")
            .replacingOccurrences(of: Transform.dots.rawValue, with: "")
        }
        .flatMap { $0.splitWordsDigits() }
        .filter { !$0.isEmpty }
    } else {
      let pattern = "[A-Z]?[a-z]+|[A-Z]+(?![a-z])|\\d+|[-_.]"
      do {
        let regex = try NSRegularExpression(pattern: pattern)
        let results = regex.matches(in: subject, range: NSRange(subject.startIndex..., in: subject))
        return results.map {
          String(subject[Range($0.range, in: subject)!])
        }
        .flatMap { $0.splitWordsDigits() }
        .filter { !$0.isEmpty }
      } catch {
        print("Invalid regex: \(error.localizedDescription)")
        return []
      }
    }
  }
  
  public func split(to kind: Transform) -> String {
    switch kind {
    case .kebab, .snake, .dots:
      let words = wordsInCamelCaseOrOneOfTheTransformSeparators()
      guard let start = words.first?.lowercased() else {
        return ""
      }
      return words
        .dropFirst()
        .reduce(start) { partialResult, word in
          "\(partialResult)\(kind.rawValue)\(word.lowercased())"
        }
    case .camelCase:
      return self.camelCase()
    }
  }
  
  @available(*, deprecated, renamed: "split(to:)", message: "As it splits from anything rather then from camelcase the name did not apply anymore")
  public func camelCase(to kind: Transform) -> String {
    split(to: kind)
  }
  
  public enum Transform: String, CaseIterable {
    case kebab = "-"
    case snake = "_"
    case dots = "."
    case camelCase = ""
  }
  
  public func camelCase() -> String {
    let words = wordsInCamelCaseOrOneOfTheTransformSeparators()
    guard let start = words.first?.lowercased() else {
      return ""
    }
    return words
      .dropFirst()
      .reduce(start) { partialResult, word in
        let lowerCased = word.lowercased()
        if let last = partialResult.last, last.isNumber {
          return "\(partialResult)\(lowerCased.lowercasedFirstCharacter())"
        } else {
          return "\(partialResult)\(lowerCased.capitalizingFirstLetter())"
        }
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
