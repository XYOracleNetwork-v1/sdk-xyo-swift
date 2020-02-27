import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(sdk_xyo_swiftTests.allTests),
    ]
}
#endif
