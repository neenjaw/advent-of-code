# Clojure Advent of Code day template

This is a self-contained day project using the Clojure CLI (`deps.edn`) and
`clojure.test`. It is designed for VS Code with Calva.

## Open in VS Code and use Calva

1. Copy this folder to the day's solution directory and open that directory
   itself in VS Code (not just an individual source file).
2. Install the recommended **Calva** extension (`betterthantomorrow.calva`).
   VS Code should offer it from the workspace recommendations.
3. Open a `.clj` file, run **Calva: Start a Project REPL and Connect (aka
   Jack-In)** from the Command Palette, and
   choose the Clojure CLI / `deps.edn` project. Include the `:test` alias so
   Calva can see the test source path. The project starts with a minimal
   Clojure REPL; no nREPL dependency needs to be added to this template.
4. Open `test/aoc/solution_test.clj` and run **Calva: Run Tests for Current
   Namespace** or **Calva: Run All Tests** from the Command Palette. You can
   also evaluate forms and call solution functions directly in the REPL.

Calva test commands can be run again after editing; test results appear in
VS Code's Test Results view / Calva output.

## Terminal commands

Run these commands from the day directory:

```sh
# Run all tests (the :test/run alias invokes this project's clojure.test runner)
clojure -M:test/run

# Run using input.txt in this directory
clojure -M -m aoc.runner

# Run using a different file, such as a sample fixture
clojure -M -m aoc.runner test/samples/part1.txt
```

The runner resolves paths relative to the current working directory, reads raw
input text, and prints labeled answers. Create your personal `input.txt` in this
folder; it is ignored by Git. Sample fixtures under `test/samples/` are tracked.

## Project structure

```text
deps.edn                       # CLI dependencies and :test / :test/run aliases
.vscode/extensions.json        # Recommends Calva
.gitignore                     # Ignores personal input.txt
src/aoc/solution.clj           # Puzzle logic
src/aoc/runner.clj             # File I/O and labeled answer output
test/aoc/solution_test.clj     # clojure.test tests calling solution functions
test/aoc/test_runner.clj       # Terminal test entry point
test/samples/                  # Trackable sample inputs
README.md                      # This guide
```

`deps.edn` has no puzzle-specific libraries by default. To add a dependency for
this day, add it under `:deps`, for example:

```clojure
:deps {org.clojure/clojure {:mvn/version "1.12.0"}
       some.group/library {:mvn/version "1.2.3"}}
```

## Solution interface

Implement `aoc.solution/part-1` and `aoc.solution/part-2` as functions taking
the complete, unmodified input string and returning an answer:

```clojure
(defn part-1 [input]
  ;; Parse input and compute the answer.
  )

(defn part-2 [input]
  ;; Parse input and compute the answer.
  )
```

Call them directly in tests or at the REPL, e.g.
`(aoc.solution/part-1 "1\n2\n3\n")`. Keep file I/O and printing in
`aoc.runner`, not in puzzle functions. The runner prints Part 2 only if
`aoc.solution/part-2` is defined, so a day with no Part 2 needs no dummy
function or answer. Remove the Part 2 tests in that case.

The included implementation is deliberately simple scaffolding: Part 1 sums
integer lines and Part 2 finds the maximum. Replace it, its sample fixtures,
and the expected values in the tests with the day's puzzle and examples. The
two parts load separate fixtures so their samples can differ.

## Clojure version

This starter currently declares Clojure 1.12.0 in `deps.edn`. It was validated
with Clojure CLI 1.12.7.1681 and Java 27.0.1.1. The repository-wide toolchain
version-pinning policy remains open; these template choices do not settle that
policy.
