# 🎄 Advent of Code - Ruby Day Template

A lightweight, self-contained Ruby template for a single day of Advent of Code.

## 🚀 Quick Start

### Zero Dependencies (Ruby 2.0+)

This template uses only Ruby's standard library - **no `bundle install` needed!**

Rake and Minitest are included in Ruby 2.0+, so you can start immediately:

```bash
# Run tests
rake

# Run the solution with default input.txt
rake run

# Run with a custom input file
rake run[my_input.txt]
```

### Optional: Using Additional Gems

If you want to use gems like `pry` for debugging, you can add a `Gemfile` (see the optional `Gemfile` in this template). Then:

```bash
bundle install
bundle exec rake run
```

### File Structure

```text
day01/
  ├── solution.rb      # Your solution class (Solution)
  ├── solution_test.rb # Tests with sample input in heredoc
  ├── Rakefile         # Simple rake tasks
  ├── input.txt        # Your puzzle input
  ├── Gemfile          # Optional: for additional gems
  └── README.md        # This file
```

## 📝 Usage

### 1. Edit `solution.rb`

Implement your `Solution` class with `part1` and `part2` methods:

```ruby
class Solution
  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.split("\n")
  end

  def part1
    # Your Part 1 logic here
  end

  def part2
    # Your Part 2 logic here
  end
end
```

### 2. Update Tests

Edit `solution_test.rb` to add your test cases. The sample input is already in a heredoc:

```ruby
SAMPLE_INPUT = <<~INPUT
  your
  test
  data
INPUT
```

### 3. Run

```bash
# Test your solution
rake

# Run with puzzle input
rake run
```

## 🎯 Why This Template?

- **Zero dependencies** - Uses only Ruby stdlib (Rake & Minitest included)
- **Self-contained** - Everything in one folder, easy to copy/drop
- **Simple** - No complex autoloading or project structure
- **Testable** - Includes test setup with sample data

Perfect for giving people a taste of Ruby! 🎉
