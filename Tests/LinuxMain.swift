import XCTest

import SwiftCMATests

var tests = [XCTestCaseEntry]()
tests += CMAESIntegrationTests.allTests()
tests += EigenDecompositionTests.allTests()
tests += LinearAlgebraTests.allTests()
XCTMain(tests)
