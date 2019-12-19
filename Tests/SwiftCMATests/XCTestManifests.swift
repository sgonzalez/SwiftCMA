import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
		testCase(CMAESIntegrationTests.allTests),
		testCase(CheckpointingTests.allTests),
		testCase(EigenDecompositionTests.allTests),
		testCase(LinearAlgebraTests.allTests)
    ]
}
#endif
