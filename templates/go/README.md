# Go Advent of Code day template

A copied day is a self-contained Go module with no third-party dependencies.

## Requirements and commands

Use Go 1.27.4, as declared in `go.mod`. Run commands from this directory:

```sh
# Run the tests
go test ./...

# Run with input.txt
go run .

# Run with a different input file
go run . samples/part1.txt
```

The personal `input.txt` is ignored by Git; sample fixtures under `samples/`
remain trackable.

## Files

```text
main.go             # Input-file handling and answer output
solution.go         # Puzzle logic
solution_test.go    # Sample tests
samples/            # Trackable sample inputs
input.txt           # Your personal puzzle input (ignored)
go.mod              # Module and Go version
go.sum              # Dependency checksums (generated if needed)
```

## Solution interface

Implement puzzle logic in `solution.go`. Each part receives the complete raw
input as a `string` and returns its answer as a string:

```go
func part1(input string) string {
	// Parse and solve Part 1
}

func part2(input string) (string, bool) {
	// Return the answer and true when this day has Part 2.
	// Return "", false when there is no second part.
}
```

The runner owns file I/O and printing. It reads `input.txt` by default or
accepts a path argument, then prints labeled answers. Tests call the solution
functions directly and load their own sample fixtures, so the parts can use
different examples. Replace the demonstration logic, fixtures, and expected
answers with the day's puzzle.

Add a dependency to this day only when needed with `go get <module>`. Go updates
`go.mod` and `go.sum` for the dependencies used by that day.
