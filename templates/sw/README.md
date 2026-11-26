# Swift Advent of Code day template

A copied day is a self-contained Swift Package with no third-party
dependencies.

## Requirements and commands

Install Swift 6.0 or newer. Run commands from this directory:

```sh
# Run the tests
swift test

# Run with input.txt
swift run AocDay

# Run with a different input file
swift run AocDay Tests/AocDayTests/Fixtures/part1.txt
```

The personal `input.txt` is ignored by Git; sample fixtures under `Tests/` are
tracked. SwiftPM resolves fixture paths through the test bundle, so tests do not
depend on the current working directory.

### If XCTest cannot be found

If `swift test` reports that it cannot find `XCTest` because Command Line Tools
are selected, point this shell session at Xcode:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test
```

This applies to commands launched from the current shell and does not change
the system-wide developer directory.

## Files

```text
Package.swift                                  # Swift package and targets
Sources/AocDay/main.swift                     # Input handling and answer output
Sources/AocDay/Solution.swift                 # Puzzle logic
Tests/AocDayTests/SolutionTests.swift         # Sample tests
Tests/AocDayTests/Fixtures/                   # Trackable sample inputs
input.txt                                      # Your personal puzzle input (ignored)
```

## Solution interface

Implement puzzle logic in `Sources/AocDay/Solution.swift`. Each part receives
the complete raw input as a `String` and returns its answer as a string:

```swift
enum Solution {
    static func part1(_ input: String) -> String {
        // Parse and solve Part 1
    }

    static func part2(_ input: String) -> String? {
        // Return an answer when this day has Part 2.
        // Return nil when there is no second part.
    }
}
```

The executable reads `input.txt` by default or accepts a file path, then prints
labeled answers. Tests call the solution functions directly and load their own
fixtures, so the parts can use different examples. Replace the demonstration
logic, fixtures, and expected answers with the day's puzzle.

The package uses Swift tools version 6.0 as its minimum; it was checked with
Swift 6.4.2.
