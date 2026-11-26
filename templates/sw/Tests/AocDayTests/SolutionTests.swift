import Foundation
import XCTest
@testable import AocDay

final class SolutionTests: XCTestCase {
    func testPart1Sample() throws {
        let input = try loadSample("part1")
        XCTAssertEqual(Solution.part1(input), "3")
    }

    func testPart2Sample() throws {
        let input = try loadSample("part2")
        XCTAssertEqual(Solution.part2(input), "10")
    }

    private func loadSample(_ name: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "txt") else {
            throw SampleError.notFound(name)
        }

        return try String(contentsOf: url, encoding: .utf8)
    }
}

private enum SampleError: Error {
    case notFound(String)
}
