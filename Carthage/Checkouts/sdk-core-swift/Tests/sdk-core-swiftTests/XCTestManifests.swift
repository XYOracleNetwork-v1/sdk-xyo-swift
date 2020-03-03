import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(sdk_core_swiftTests.allTests),
    ]
}
#endif
