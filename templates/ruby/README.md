# 🎄 Advent of Code Ruby Template

This is a minimal template for Advent of Code, featuring **Bundler** for dependency management, **Zeitwerk** for frictionless class autoloading, **Minitest** for testing, and a **Rake** interface for running solutions.

---

## 🛠️ 1. Setup and Installation

### 1.1. 💎 Ruby Version Management (Using `mise`)

We recommend using `mise en place` (`mise`) to manage your Ruby versions cleanly.

#### **A. Install `mise`**

If you don't have it, install `mise` using your preferred method (e.g., Homebrew or the installer script):

```bash
# Option 1: Homebrew
brew install mise

# Option 2: Installer Script (macOS/Linux)
curl [https://mise.run](https://mise.run) | sh
````

#### **B. Activate `mise`**

Ensure `mise` is activated in your shell (`.zshrc`, `.bashrc`, etc.):

```bash
# Example for Zsh/Bash
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

#### **C. Install Project Ruby Version**

The first time you enter this directory, install the required Ruby version:

```bash
# List available versions
mise ls-remote ruby

# Install a specific version (e.g., 3.3.0)
mise install ruby@3.3.0

# Pin the version to this project (creates a .tool-versions file)
mise use ruby@3.3.0
```

### 1.2. 📦 Dependencies

Install the project's dependencies defined in the `Gemfile`:

```bash
bundle install
```

-----

## 2\. 🚀 Usage

### 2.1. 📂 File Structure

Your project structure should follow:

```text
.
├── Gemfile
├── Rakefile
├── src/
│   ├── day01.rb  # Solution classes (autoloaded as Day01)
│   └── helper.rb # Helper module (autoloaded as Helper)
└── test/
    └── day01_test.rb # Minitest files
```

### 2.2. 📝 Creating a New Solution

1. Create a new solution file in `src/`, following the format `dayXX.rb` (e.g., `day02.rb`).

2. Define the class name to match the file name (e.g., `class Day02` in `src/day02.rb`).

3. Implement the standard interface:

    ```ruby
    class DayXX
      def initialize(input_data)
        # Process input here
      end

      def part1
        # Part 1 logic
      end

      def part2
        # Part 2 logic
      end
    end
    ```

### 2.3. ▶️ Running Solutions

Use the `rake day` command, which automatically loads your class via Zeitwerk.

| Action | Command | Notes |
| :--- | :--- | :--- |
| **Run Day 01** | `bundle exec rake day01 input/01.txt` | Runs the solution with a specific input file. |
| **Default Input** | `bundle exec rake day01` | Assumes the input is at `input/day01.txt`. |
| **From STDIN** | `cat my_input.txt \| bundle exec rake day01` | Runs with piped input if no file is found. |

### 2.4. 🧪 Running Tests (Minitest)

All files in the `test/` directory ending in `_test.rb` will be executed.

```bash
# Runs all tests
bundle exec rake test

# 'test' is the default rake task
bundle exec rake
```
