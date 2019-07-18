import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftGoTests.allTests),
        testCase(BsonDecoderTests.allTests),
    ]
}
#endif
