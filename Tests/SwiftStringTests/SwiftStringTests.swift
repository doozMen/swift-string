import XCTest
import SnapshotTesting
import RegexBuilder

@testable import SwiftString

final class StringTests: XCTestCaseSnapshot {
  
  func testSplitWordsLetters() {
    XCTAssertEqual(
      "plus26".splitWordsDigits(),
      ["plus", "26"])
    
    XCTAssertEqual(
      "plus".splitWordsDigits(),
      ["plus"])
  }
  
  func testCapitalOrNumberAsSeparator() {
    XCTAssertEqual(
      "word1Word2Word3-1234-word4Word5".wordsInCamelCaseOrOneOfTheTransformSeparators(),
      ["word", "1", "Word", "2", "Word", "3", "1234", "word", "4", "Word", "5"])
    
    XCTAssertEqual(
      "whatDoes-690_ItDo".wordsInCamelCaseOrOneOfTheTransformSeparators(),
      ["what", "Does", "690", "It", "Do"])
    XCTAssertEqual(
      "gradient.neutral.100-bottom-to-50%".wordsInCamelCaseOrOneOfTheTransformSeparators(),
      ["gradient", "neutral", "100", "bottom", "to", "50"])
    
    XCTAssertEqual(
      "plus26Logo".wordsInCamelCaseOrOneOfTheTransformSeparators(),
      ["plus", "26", "Logo"])
  }
  
  func testIndent() {
    let sut = """
    // Should
        Not
            move

    // Ok

    """

    assertSnapshot(matching: sut.indentNonEmpty(.spaces(2, tabs: 3)), as: .lines)
  }

  func testCamelcase() {
    let expected = "whatDoesItDo"
    XCTAssertEqual("what.does.it.do".camelCase(), expected)
    XCTAssertEqual("what-does-it-do".camelCase(), expected)
    XCTAssertEqual("what_does_it_do".camelCase(), expected)
    XCTAssertEqual("what Does it do".camelCase(), expected)
    XCTAssertEqual(expected.camelCase(), expected)
  }
  
  
  func testCamelCaseMixed() {
    let sut = "semantic.foreground.onBrand.static.default.fill"
    
    XCTAssertEqual(sut.camelCase(), "semanticForegroundOnBrandStaticDefaultFill")
  }

  func testSnakeCase() {
    XCTAssertEqual("WhatDoesItDo".camelCase(to: .kebab), "what-does-it-do" )
    XCTAssertEqual("whatDoesItDo".camelCase(to: .kebab), "what-does-it-do" )

    XCTAssertEqual("whatDoesItDo".camelCase(to: .kebab), "what-does-it-do" )
    XCTAssertEqual("whatDoesItDo".camelCase(to: .snake), "what_does_it_do" )
    XCTAssertEqual("whatDoes-690_ItDo".camelCase(to: .snake), "what_does_690_it_do" )
    XCTAssertEqual("gradient.neutral.100-bottom-to-50%".camelCase(to: .snake), "gradient_neutral_100_bottom_to_50" )
    XCTAssertEqual("whatDoesItDo".camelCase(to: .dots), "what.does.it.do" )
    XCTAssertEqual("plus26Logo".camelCase(to: .dots), "plus.26.logo" )
  }

  func testCapitalizeFirstLetter() {
    var sut = "whatDoesItDo"
    sut.capitalizeFirstLetter()
    XCTAssertEqual(sut, "WhatDoesItDo" )
  }

  func testCapitalizingFirstLetter (){
    XCTAssertEqual("whatDoesItDo".capitalizingFirstLetter(), "WhatDoesItDo")
  }

  func testLowercasedFirstCharacter(){
    XCTAssertEqual("whatDoesItDo".lowercasedFirstCharacter(), "whatDoesItDo")
  }

}

open class XCTestCaseSnapshot: XCTestCase {
  open override class func setUp() {
    super.setUp()
    SnapshotTesting.diffTool = "ksdiff"
    let isRecording = Bool(ProcessInfo.processInfo.environment["be.dooz.update.tests"] ?? "false") ?? false
    SnapshotTesting.isRecording = isRecording
  }
}
