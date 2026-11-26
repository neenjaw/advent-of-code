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

Template directories use the same codes as the language folders created for a
day:

| Code | Language |
| --- | --- |
| `cl` | Clojure |
| `ex` | Elixir |
| `gl` | Gleam |
| `go` | Go |
| `js` | JavaScript |
| `php` | PHP |
| `py` | Python |
| `rb` | Ruby |
| `rs` | Rust |
| `sw` | Swift (template not yet available) |

## Create a day

Use the scaffold script with a year, day number, and template code:

```sh
python3 scripts/new-day.py 2026 1 rb
```

This copies `templates/rb/` to `2026/01/rb/`. It refuses to overwrite an
existing destination and skips personal inputs and generated build/cache
artifacts.

## Decisions still to make

- The exact version-management policy for the language toolchains.
- Build the Swift template from the original 2026 language list.
