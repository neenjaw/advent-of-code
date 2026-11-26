"""Read a puzzle input file and print the available solution answers."""

import argparse
from pathlib import Path
from typing import Sequence

import solution


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run the Advent of Code solution.")
    parser.add_argument(
        "input_file",
        nargs="?",
        type=Path,
        help="input file (default: input.txt in this directory)",
    )
    args = parser.parse_args(argv)

    input_file = args.input_file or Path(__file__).parent / "input.txt"
    input_text = input_file.read_text()

    for label, function_name in (("Part 1", "part1"), ("Part 2", "part2")):
        function = getattr(solution, function_name, None)
        if callable(function):
            print(f"{label}: {function(input_text)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
