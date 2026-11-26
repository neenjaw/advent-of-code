# Gleam Advent of Code day template

A copied day is a standalone Gleam package. Gleam manages the project and its
dependencies; `simplifile` provides file input and `gleeunit` provides tests.

## Requirements

- Gleam 1.13 or newer
- Erlang/OTP (the default Erlang target)

## Run and test

Run commands from this directory:

```sh
# Run with input.txt
gleam run

# Run with a different input file
gleam run samples/part1.txt

# Run tests
gleam test
```

Gleam downloads the dependencies declared in `gleam.toml` when needed. The
generated `manifest.toml` records resolved versions and should be committed.

## Files

```text
src/aoc_gleam.gleam              # CLI, input handling, and answer output
src/aoc_gleam/solution.gleam     # Puzzle logic
test/aoc_gleam_test.gleam        # Sample tests
samples/                         # Trackable sample inputs
input.txt                        # Personal puzzle input (ignored)
gleam.toml                       # Project and dependency configuration
manifest.toml                    # Resolved dependencies (generated)
```

## Solution interface

Implement `part1` and `part2` in `src/aoc_gleam/solution.gleam`. Both receive
the complete raw input as a `String`. Return the answer as a string so numeric
and text answers are both supported:

```gleam
pub fn part1(input: String) -> String {
  // Parse and solve Part 1
}

pub fn part2(input: String) -> Option(String) {
  // Return Some(answer) when this day has Part 2.
  // Return None when there is no second part.
}
```

The runner reads `input.txt` by default or accepts a path after `--`, then
prints labeled answers. Tests call the solution functions directly and load
their own sample fixtures, so the parts can use different examples. Replace the
demonstration logic, fixtures, and expected answers with the day's puzzle.

Add any further dependencies to this day's `gleam.toml` only when needed. The
template includes `argv` for command-line arguments and `simplifile` for file
input; neither is part of Gleam's standard library.
