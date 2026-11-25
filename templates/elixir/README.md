# Advent of Code template (Elixir)

This is a dependency-free `.exs` setup. Copy this directory into a day's
solution folder, add your puzzle input as `input.txt`, and edit `solution.exs`.
The template was validated with Elixir 1.20.5 on Erlang/OTP 29; no specific
version manager is required.

## Setup

Install Elixir using your preferred package manager or version manager. No Mix
project, dependency installation, or extra test framework is needed.

## Commands

Run from this directory:

```sh
elixir run.exs                 # reads input.txt
elixir run.exs sample_part1.txt # use a different input file
elixir test.exs
```

An input-file path is interpreted relative to the current working directory.
The default `input.txt` path is relative to `run.exs`. The runner prints
`Part 1: ...` and, when implemented, `Part 2: ...`.

## Files

- `solution.exs` — puzzle logic, with no file I/O or answer printing.
- `run.exs` — reads input and prints answers.
- `test.exs` — built-in ExUnit tests.
- `sample_part1.txt`, `sample_part2.txt` — independent sample fixtures; adjust
  or add fixtures as needed.
- `.gitignore` — keeps the personal `input.txt` out of version control.

## Solution interface

Define public `Solution.part1/1` and, when the puzzle has a second part,
`Solution.part2/1`. Each function receives the **raw input string** and returns
its answer. Keep parsing and puzzle logic in these functions; the runner owns
file reading and normal output. The runner checks whether `part2/1` exists, so
remove that function when there is no second part rather than returning a
placeholder answer. The included implementation is a small working example;
replace it with the day's puzzle logic.
