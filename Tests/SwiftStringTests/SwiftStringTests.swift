import XCTest
import SnapshotTesting

@testable import SwiftString

final class StringTests: XCTestCaseSnapshot {

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
    XCTAssertEqual("whatDoesItDo".camelCase(to: .kebab), "what-does-it-do" )
    XCTAssertEqual("whatDoesItDo".camelCase(to: .snake), "what_does_it_do" )
    XCTAssertEqual("whatDoes69ItDo".camelCase(to: .snake), "what_does_69_it_do" )
    XCTAssertEqual("whatDoesItDo".camelCase(to: .dots), "what.does.it.do" )
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
