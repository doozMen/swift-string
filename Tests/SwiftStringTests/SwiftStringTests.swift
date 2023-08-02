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

open class XCTestCaseSnapshot: XCTestCase {
  open override class func setUp() {
    super.setUp()
    SnapshotTesting.diffTool = "ksdiff"
    let isRecording = Bool(ProcessInfo.processInfo.environment["be.dooz.update.tests"] ?? "false") ?? false
    SnapshotTesting.isRecording = isRecording
  }
}
