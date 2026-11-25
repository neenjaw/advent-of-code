# Python Advent of Code day template

A copied day is self-contained and uses Python's standard library by default.
`uv` manages the project and its per-day environment; no test or runtime
dependencies are needed for the starter.

## Setup and commands

Install `uv` and Python 3.11 or newer. From the day directory, sync the locked
environment and run the tests:

```sh
uv sync --locked
uv run python -m unittest discover -s tests -v
```

Run with `input.txt` in this directory, or pass a different input path:

```sh
uv run python run.py
uv run python run.py samples/part1.txt
```

The runner prints labeled answers for the parts the solution implements.
Personal puzzle input in `input.txt` is ignored by Git; sample fixtures under
`samples/` remain trackable.

## Optional dependencies

Add a dependency to this day only with `uv add`. For example:

```sh
uv add numpy
# or: uv add z3-solver
```

`uv` updates this day's `pyproject.toml` and `uv.lock`. Use it from the day
directory to install and run with the dependency:

```sh
uv sync --locked
uv run python run.py
```

Import NumPy as `numpy`, or Z3 as `z3`, in the solution that needs it. Each day
has its own project metadata, lock file, and `.venv`; dependencies do not leak
into other days.

## Files

```text
run.py                  Input-file handling and answer output
solution.py             Puzzle logic
tests/test_solution.py  Standard-library unittest tests
samples/                Trackable sample input fixtures
input.txt               Your personal puzzle input (ignored)
pyproject.toml          Project metadata and direct dependencies
uv.lock                 Reproducible resolved environment
.gitignore              Local environment, cache, and input ignores
README.md               This guide
```

## Solution interface

Implement puzzle logic in `solution.py` as functions that receive the complete
raw input text and return their answer:

```python
def part1(input_text: str) -> int:
    ...


def part2(input_text: str) -> int:
    ...
```

Tests call these functions directly. Keep file I/O and printing in `run.py`,
not in the solution. The runner reads `input.txt` by default, accepts an input
path argument, and prints answers as `Part 1: ...` and `Part 2: ...`. If a
puzzle has no second part, remove `part2`; the runner will omit it.

Each part's test loads its own fixture, so different samples can be used when
needed. Replace the example logic, samples, and expected results with the day's
puzzle.

The project declares Python `>=3.11` as its compatibility floor, not an exact
interpreter pin. This template was tested with Python 3.12.13 and uv 0.11.3;
the repository-wide tool-version policy remains open.
