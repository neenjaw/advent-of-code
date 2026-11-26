# Advent of Code

Solutions are organized by year, day, and language:

```text
<year>/<two-digit-day>/<language-code>/
```

## Template conventions

These conventions guide the self-contained day templates:

- Each day's solution is self-contained and can be run and tested from its own
  directory, without depending on shared code or another day's solution.
- Each language template provides a documented command to run the solution and
  a documented command to run its tests. The commands may be language-specific.
- The runner reads `input.txt` by default and accepts an input-file path
  override. It passes raw input text to the solution; parsing belongs to the
  solution.
- Puzzle logic is callable by tests. File I/O and normal answer output belong
  in the runner, not in the puzzle logic.
- Templates include sample fixtures and tests for both puzzle parts. They allow
  different sample cases where the parts require them.
- Normal output labels answers clearly, for example `Part 1: ...` and
  `Part 2: ...`, without debug output.
- A day with no second part does not need to provide a dummy answer.
- Prefer standard libraries and built-in test frameworks. Add dependencies only
  when they provide clear value.
- Personal puzzle inputs must not be committed; sample fixtures must remain
  trackable.
- Each template records enough tool-version information to make its setup
  reproducible.

## Available templates

Templates are currently available in `templates/` for Clojure, Elixir, Gleam,
Go, Node.js, PHP, Python, Ruby, and Rust. Swift was part of the original 2026
language list but does not yet have a template.

## Decisions still to make

- The two-letter language codes and their mapping to language names.
- The exact version-management policy for the language toolchains.
