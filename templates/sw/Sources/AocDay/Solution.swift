enum Solution {
    static func part1(_ input: String) -> String {
        String(input.split(whereSeparator: \.isNewline).count)
    }

    static func part2(_ input: String) -> String? {
        String(input.utf8.count)
    }
}
