import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

private enum CommandLineError: Error, CustomStringConvertible {
    case usage

    var description: String {
        switch self {
        case .usage:
            "Usage: swift run AocDay [input-file]"
        }
    }
}

@main
private struct AocDay {
    static func main() {
        do {
            try run()
        } catch {
            FileHandle.standardError.write(Data("Error: \(error)\n".utf8))
            exit(EXIT_FAILURE)
        }
    }

    private static func run() throws {
        var arguments = Array(CommandLine.arguments.dropFirst())
        if arguments.first == "--" {
            arguments.removeFirst()
        }

        guard arguments.count <= 1 else {
            throw CommandLineError.usage
        }

        let inputPath = arguments.first ?? "input.txt"
        let input = try String(contentsOfFile: inputPath, encoding: .utf8)

        print("Part 1: \(Solution.part1(input))")

        if let answer = Solution.part2(input) {
            print("Part 2: \(answer)")
        }
    }
}
