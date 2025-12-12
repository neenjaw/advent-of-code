# Advent of Code Day Template (Elixir)

A lightweight Elixir script template for solving Advent of Code problems.

## Setup

1. Copy this entire folder to your day folder (e.g., `day01/`, `day02/`, etc.)
2. Ensure you have Elixir installed (via `mise` or your preferred method)
3. Edit `solution.exs` with your solution
4. Add your input to `input.txt`

## Usage

### Run your solution

```bash
elixir .scripts/run.exs
# or with a custom input file
elixir .scripts/run.exs sample.txt
```

### Run tests

```bash
elixir .scripts/test_runner.exs
```

## File Structure

- `solution.exs` - Your solution (defines a `Solution` module with a `solve/1` function)
- `test.exs` - Your tests using ExUnit (edit this file with your test cases)
- `input.txt` - Your puzzle input
- `.scripts/run.exs` - Script to run your solution with nice output
- `.scripts/test_runner.exs` - Test runner that loads your test file
- `.scripts/utils.exs` - Common utilities (read_input_lines, etc.)
- `mise.toml` - Version management (optional, if using mise)

## Requirements

- Elixir 1.19+ (or as specified in `mise.toml`)
- ExUnit (included with Elixir)

## Solution Format

Your `solution.exs` should define a `Solution` module with a `solve/1` function:

```elixir
defmodule Solution do
  def solve(input_lines) do
    part1 = part1(input_lines)
    part2 = part2(input_lines)

    %{part1: part1, part2: part2}
  end

  defp part1(input_lines) do
    # Your part 1 solution
  end

  defp part2(input_lines) do
    # Your part 2 solution
  end
end
```

## Using Hex Dependencies

To use packages from hex.pm, you can use `Mix.install/1` directly in your script (Elixir 1.12+). See the commented example at the top of `.scripts/run.exs`:

```elixir
Mix.install([
  {:req, "~> 0.5"}
])
```

This will automatically download and install the packages when you run the script - no `mix.exs` or `mix deps.get` needed!

Alternatively, if you prefer a traditional Mix project:

1. Create a `mix.exs` file in the same directory
2. Run `mix deps.get` to install dependencies
3. Run your scripts with `mix run solution.exs` or `mix run .scripts/run.exs`

Example `mix.exs`:

```elixir
defmodule Day01.MixProject do
  use Mix.Project

  def project do
    [
      app: :day01,
      version: "0.1.0",
      deps: deps()
    ]
  end

  defp deps do
    [
      # Add your dependencies here
      # {:some_dep, "~> 1.0"}
    ]
  end
end
```

## Notes

- All files use `.exs` (script) extension for easy execution
- Scripts use `Code.require_file/2` to load dependencies
- The template is designed to be self-contained and portable
