import XCTest
import SnapshotTestingCli
import InlineSnapshotTesting
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
  
  func testSplitWithoutCamelCase() {
    XCTAssertEqual("WHAT_doeS_IT_DO".splitWithoutCamelCase(),
                   ["WHAT", "doeS", "IT", "DO"])
  }
  
  func testCapitalOrNumberAsSeparator() {
    XCTAssertEqual("WHAT_does_IT_DO".wordsInCamelCaseOrOneOfTheTransformSeparators(),
                   ["what", "does", "it", "do"])
    
    XCTAssertEqual("WHAT_DOES_IT_DO".wordsInCamelCaseOrOneOfTheTransformSeparators(),
                   ["what", "does", "it", "do"])
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
    
    assertInlineSnapshot(of: sut.indentNonEmpty(.spaces(2, tabs: 3)), as: .lines) {
    """
          // Should
              Not
                  move
    
          // Ok

    """
    }
  }
  
  func testCamelcase() {
    let expected = "whatDoesItDo"
    XCTAssertEqual("what.does.it.do".camelCase(), expected)
    XCTAssertEqual("what-does-it-do".camelCase(), expected)
    XCTAssertEqual("what_does_it_do".camelCase(), expected)
    XCTAssertEqual("what Does it do".camelCase(), expected)
    XCTAssertEqual("WHAT_DOES_IT_DO".camelCase(), expected)
    XCTAssertEqual("gradient.neutral.100-bottom-to-50%".camelCase(), "gradientNeutral100BottomTo50" )
    XCTAssertEqual(expected.camelCase(), expected)
  }
  
  
  func testCamelCaseMixed() {
    let sut = "semantic.foreground.onBrand.static.default.fill"
    
    XCTAssertEqual(sut.camelCase(), "semanticForegroundOnBrandStaticDefaultFill")
  }
  
  func testSnakeCase() {
    XCTAssertEqual("WhatDoesItDo".split(to: .kebab), "what-does-it-do" )
    XCTAssertEqual("whatDoesItDo".split(to: .kebab), "what-does-it-do" )
    
    XCTAssertEqual("whatDoesItDo".split(to: .kebab), "what-does-it-do" )
    XCTAssertEqual("whatDoesItDo".split(to: .snake), "what_does_it_do" )
    XCTAssertEqual("whatDoes-690_ItDo".split(to: .snake), "what_does_690_it_do" )
    XCTAssertEqual("gradient.neutral.100-bottom-to-50%".split(to: .snake), "gradient_neutral_100_bottom_to_50" )
    XCTAssertEqual("whatDoesItDo".split(to: .dots), "what.does.it.do" )
    XCTAssertEqual("plus26Logo".split(to: .dots), "plus.26.logo" )
    XCTAssertEqual("whatDoes-690_ItDo".split(to: .camelCase), "whatDoes690ItDo" )
  }
  
  func testCamelCase_noUpperCaseAfterNumber() {
    XCTAssertEqual("whatDoes-690_ItDo".camelCase(), "whatDoes690ItDo")
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
