import Flutter
import UIKit
import XCTest

@testable import flutter_security_detection

// Unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testUnknownMethodIsNotImplemented() {
    let plugin = FlutterSecurityDetectionPlugin()

    let call = FlutterMethodCall(methodName: "doesNotExist", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertTrue((result as AnyObject) === FlutterMethodNotImplemented)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
