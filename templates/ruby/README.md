# Ruby Advent of Code day template

A copied day is self-contained. It uses Ruby's standard library and Minitest.
Rake is an optional convenience for shorter commands; direct Ruby commands are
available without it. There is no Gemfile or bundle install step.

## Setup and commands

Install Ruby with Minitest available. To use the short commands, also install
Rake if it is not already available (`gem install rake`). Run from the day
directory:

```sh
# Run the tests (rake with no task runs the default test task)
rake

# Run with input.txt in this directory
rake run

# Run with a sample or another input file
INPUT=samples/part1.txt rake run
```

You can also use Ruby directly without Rake:

```sh
# Run the tests
ruby -Itest test/solution_test.rb

# Run with input.txt in this directory
ruby run.rb

# Run with a sample or another input file
ruby run.rb samples/part1.txt
```

The runner resolves both the default input path and a relative path argument
from the day directory. It prints labeled answers and reads `input.txt` by
default. The personal `input.txt` is ignored by Git; sample fixtures under
`samples/` are tracked.

## Files

```text
run.rb                 # Input-file handling and answer output
Rakefile                # Optional short commands: rake, rake run
solution.rb            # Puzzle logic
test/solution_test.rb  # Minitest tests
samples/                # Trackable sample inputs
input.txt               # Your personal puzzle input (ignored)
README.md               # This guide
```

## Solution interface

Implement puzzle logic as methods on the `Solution` module. Each method takes
the complete, unmodified input text as a string and returns its answer:

```ruby
module Solution
  def self.part1(input)
    # Parse and solve Part 1
  end

  def self.part2(input)
    # Parse and solve Part 2
  end
end
```

The runner owns file I/O and printing; methods in `solution.rb` should not read
files or print answers. Tests call these methods directly. If a puzzle has no
Part 2, remove `part2`; the runner prints only the parts the module implements.

The sample solver and fixtures demonstrate the interface with increasing
measurements. Replace them with the day's puzzle logic and samples. Each part
loads its own fixture in the tests, so the samples can differ when needed.

## Ruby version

This template has no exact Ruby version pin. It was tested with Ruby 4.0.10,
Minitest 6.0.0, and Rake 13.3.1. Choosing an exact Ruby version or version
manager for this template remains an open Ruby-specific decision and does not
settle the repository-wide version-management policy.
