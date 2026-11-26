# Advent of Code JavaScript Template

A standalone, dependency-free Node.js template for one Advent of Code day.
Copy this directory to a day folder and work only within that copy.

## Setup

Use Node.js 20 or newer and npm. There are no external packages to install;
`package.json` provides commands for running the solution and tests.

After copying this directory:

1. Replace the example logic in `index.js`.
2. Put your personal puzzle input in `input.txt`.
3. Update the sample fixtures and expected answers in `index.test.js`.

Personal input files named `input*.txt` are ignored by git. The fixtures under
`samples/` are not ignored and should be committed.

## Commands

Run using `input.txt` in the day directory:

```sh
npm start
```

Pass a different input path (relative to the current directory, or absolute):

```sh
npm start -- samples/part1.txt
```

Run the tests or watch for changes:

```sh
npm test
npm run test:watch
```

The runner passes the input file's raw text to the solution and prints only
available answers, labeled `Part 1:` and `Part 2:`.

## Files

```text
index.js             Puzzle logic and JSDoc interface
index.test.js        Tests using Node's built-in test runner
scripts/run.js       Input-file I/O and answer printing
samples/             Trackable sample input fixtures
input.txt            Your personal puzzle input (ignored by git)
package.json         Run and test scripts; no dependencies
```

## Solution interface

`index.js` uses native JavaScript ES modules. Export `solvePart1` and, when the
puzzle has a second part, `solvePart2`. Each function receives the complete raw
input string and returns an answer (`string`, `number`, or `bigint`). Keep file
I/O and printing in `scripts/run.js`; this keeps the puzzle functions directly
callable from tests.

The starter implementation demonstrates this interface by summing the numbers
for Part 1 and multiplying them for Part 2. Replace those examples with the
puzzle's parsing and logic. A Part 2 function is optional; omit it rather than
returning a placeholder answer.

The `// @ts-check` directive and JSDoc types at the top of `index.js` enable
VS Code's JavaScript type diagnostics without adding TypeScript or a
TypeScript configuration. No exact Node.js version is pinned while the
repository-wide version-management policy is undecided.
