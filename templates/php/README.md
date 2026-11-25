# PHP day template

Each day is self-contained. The default setup uses PHP scripts and a small
dependency-free test harness; Composer is optional for days that need packages.

## Requirements

- PHP 8.6.0 is the version used to check this template.
- No Composer installation is needed for the default setup.

The repository has not set a shared PHP version policy yet. Check your installed
version with `php --version`.

## Run

From this directory:

```sh
php run.php
php run.php path/to/input.txt
```

With no path, the runner reads `input.txt` from this directory. The runner reads
the file and passes its raw contents to `solvePart1()` and `solvePart2()`.
Solution functions should do puzzle work only; keep file I/O and normal output
in the runner.

Answers are printed with `Part 1:` and `Part 2:` labels. A `null` result means
that part is not implemented yet, and is printed as `not implemented`. You can
remove `solvePart2()` entirely if the puzzle has no second part.

## Test

```sh
php tests.php
```

Replace `sample.txt` with the puzzle's sample input. Add or adjust cases in
`tests.php`, including the expected sample answers for both parts. A `null`
expected value marks a case as pending; pending cases are reported as skipped.
Use separate sample files and test cases when the parts need different samples.

## Optional packages

For a day that needs third-party packages, add a `composer.json` in that day
directory, install packages there, and keep `vendor/` uncommitted. The runner
and test harness load `vendor/autoload.php` if it exists. Days that need no
packages do not need Composer.

## Files

- `Solution.php` — directly testable solution functions; receives raw input.
- `run.php` — input-file selection, file I/O, and labeled answers.
- `tests.php` — sample test cases and the lightweight test harness.
- `sample.txt` — tracked sample fixture; replace its contents as needed.
- `input.txt` — personal puzzle input; ignored by Git.
