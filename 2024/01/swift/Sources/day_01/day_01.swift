import Foundation

let fileName = CommandLine.arguments[1]

func readFile(path: String) throws -> String {
  let data = try Data(contentsOf: URL(fileURLWithPath: path))
  return String(data: data, encoding: .utf8)!
}

func parseContent(content: String) throws -> [(Int, Int)] {
  return
    try content
    .split(separator: "\n")
    .compactMap { line in
      let regex = try! NSRegularExpression(pattern: #"\d+"#)
      let numbers =
        regex
        .matches(in: String(line), range: NSRange(line.startIndex..<line.endIndex, in: line))
        .map { Int(String(line[Range($0.range, in: line)!]))! }
      guard numbers.count == 2 else { throw NSError() }

      return (numbers[0], numbers[1])
    }
}

func unzip<T>(_ listOfPairs: [(T, T)]) -> ([T], [T]) {
  return (
    listOfPairs.map { $0.0 },
    listOfPairs.map { $0.1 }
  )
}

do {
  let exampleFilePath = fileName
  let exampleFileContent = try readFile(path: exampleFilePath)
  let lists = try parseContent(content: exampleFileContent)

  let (left, right) = unzip(lists)
  let sortedLeft = left.sorted()
  let sortedRight = right.sorted()
  let zipped = zip(sortedLeft, sortedRight)

  let part1 = zipped.map { abs($0.1 - $0.0) }.reduce(0, +)
  print("Part 1: \(part1)")

  var frequencies: [Int: Int] = Dictionary(
    left.map { ($0, 0) }, uniquingKeysWith: { (current, _) in return current })
  right.forEach {
    if let v = frequencies[$0] {
      frequencies[$0] = v + 1
    }
  }

  let part2 = left.map { frequencies[$0]! * $0 }.reduce(0, +)
  print("Part 2: \(part2)")
} catch {
  print("Error reading file: \(error)")
}
