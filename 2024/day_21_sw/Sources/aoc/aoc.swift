import Foundation
import simd

let fileName = CommandLine.arguments[1]

func readFile(path: String) throws -> String {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    return String(data: data, encoding: .utf8)!
}

func parseContent(content: String) throws -> [String] {
    return
        content
        .split(separator: "\n")
        .map { String($0) }
}

extension Array {
    func tap(_ action: (Self) -> Void) -> Self {
        action(self)
        return self
    }
}

extension String {
    func permutations() -> Set<String> {
        guard !isEmpty else { return [] }
        guard count > 1 else { return [self] }

        var result: Set<String> = []
        for i in 0..<count {
            let index = self.index(self.startIndex, offsetBy: i)
            let char = String(self[index])
            let left = String(self[..<index])
            let right = String(self[self.index(after: index)...])
            for perm in (left + right).permutations() {
                result.insert(char + perm)
            }
        }
        return result
    }
}

extension String {
    func eachCons(n: Int) -> AnySequence<Substring> {
        guard n > 0, n <= count else { return AnySequence { AnyIterator { nil } } }
        return AnySequence { () -> AnyIterator<Substring> in
            var index = self.startIndex
            return AnyIterator {
                guard index < self.index(self.endIndex, offsetBy: -(n - 1)) else { return nil }
                let result = self[index..<self.index(index, offsetBy: n)]
                index = self.index(after: index)
                return result
            }
        }
    }
}

let doorControl: [simd_float2: String] = [
    [0, 0]: "7",
    [1, 0]: "8",
    [2, 0]: "9",
    [0, 1]: "4",
    [1, 1]: "5",
    [2, 1]: "6",
    [0, 2]: "1",
    [1, 2]: "2",
    [2, 2]: "3",
    [1, 3]: "0",
    [2, 3]: "A",
]

var reverseDoorControl: [String: simd_float2] = [:]
for (key, value) in doorControl {
    reverseDoorControl[value] = key
}

let robotControl: [simd_float2: String] = [
    [1, 0]: "^",
    [2, 0]: "a",
    [0, 1]: "<",
    [1, 1]: "v",
    [2, 1]: ">",
]

var reverseRobotControl: [String: simd_float2] = [:]
for (key, value) in robotControl {
    reverseRobotControl[value] = key
}

let directions: [String: simd_float2] = [
    "^": [0, -1],
    "v": [0, 1],
    "<": [-1, 0],
    ">": [1, 0],
]

func generatePaths(
    start: simd_float2,
    finish: simd_float2,
    controls: [simd_float2: String],
    reverseControls: [String: simd_float2]
) -> [String] {
    let delta = finish - start
    let (dy, dx) = (delta.y, delta.x)

    let horizontalDirection = dx < 0 ? "<" : ">"
    let verticalDirection = dy < 0 ? "^" : "v"
    var unitPath: String = ""
    unitPath += String(repeating: horizontalDirection, count: Int(abs(dx)))
    unitPath += String(repeating: verticalDirection, count: Int(abs(dy)))

    let permutations = unitPath.permutations()
    let paths = permutations.filter {
        return $0.map {
            let direction = directions[String($0)]!
            return direction
        }
        .reduce([start]) {
            var path = $0
            let last = path.last!
            let next = last + $1
            path.append(next)
            return path
        }.allSatisfy {
            return controls[$0] != nil
        }
    }.map { $0 + "a" }

    if paths.isEmpty {
        return ["a"]
    }
    return paths
}

var memo: [String: Int64] = [:]

@MainActor func codeToPathLength(code: String, depth: Int, limit: Int) -> Int64 {
    let memoKey = "\(code)-\(depth)-\(limit)"
    if let memoValue = memo[memoKey] {
        return memoValue
    }

    let isRoot = depth == 0
    let prefix = isRoot ? "A" : "a"
    let controls = isRoot ? doorControl : robotControl
    let reverseControls = isRoot ? reverseDoorControl : reverseRobotControl

    let result: Int64 = (prefix + code).eachCons(n: 2).reduce(0) {
        acc, substring in
        let start = reverseControls[String(substring.first!)]!
        let finish = reverseControls[String(substring.last!)]!
        let paths = generatePaths(
            start: start,
            finish: finish,
            controls: controls,
            reverseControls: reverseControls
        )

        if depth >= limit {
            return acc + Int64(paths.first!.count)
        }

        return acc + paths.map {
            codeToPathLength(code: $0, depth: depth + 1, limit: limit)
        }.min()!
    }

    memo[memoKey] = result
    return result
}

do {
    let exampleFilePath = fileName
    let exampleFileContent = try readFile(path: exampleFilePath)
    let codes = try parseContent(content: exampleFileContent)

    let p1Results = codes.map {
        let p1 = codeToPathLength(code: $0, depth: 0, limit: 2)
        let numericComponent: Int64 =
            Int64($0[$0.startIndex..<($0.index($0.endIndex, offsetBy: -1))]) ?? 0
        return ($0, numericComponent, p1, p1 * numericComponent)
    }

    p1Results.forEach {
        print($0)
    }
    print(p1Results.map { $0.3 }.reduce(0, +))

    let p2Results = codes.map {
        let p2 = codeToPathLength(code: $0, depth: 0, limit: 25)
        let numericComponent: Int64 = Int64(
            $0[$0.startIndex..<($0.index($0.endIndex, offsetBy: -1))])!
        return ($0, numericComponent, p2, p2 * numericComponent)
    }

    p2Results.forEach {
        print($0)
    }
    print(p2Results.map { $0.3 }.reduce(0, +))
} catch {
    print("Error reading file: \(error)")
}
