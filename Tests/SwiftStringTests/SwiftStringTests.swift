import XCTest
@testable import SwiftString

final class StringTests: XCTestCase {

  func testIndent() {
    let sut = """
    // Should
        Not
            move

    // Ok

    """

    let expected = """
          // Should
              Not
                  move
          // Ok
    """

    XCTAssertEqual(sut.indentNonEmpty(.spaces(2, tabs: 3)), expected)
  }

  func testCamelcase() {
    XCTAssertEqual("what-does-it-do".camelCase(), "whatDoesItDo")
  }

  func testSnakeCase() {
    XCTAssertEqual("whatDoesItDo".camelCase(to: .kebab), "what-does-it-do" )
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
