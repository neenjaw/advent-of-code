"""Example puzzle logic; functions receive raw input text."""

from math import prod


def part1(input_text: str) -> int:
    """Return the sum of the numbers in the input."""
    return sum(int(line) for line in input_text.splitlines())


def part2(input_text: str) -> int:
    """Return the product of the numbers in the input."""
    return prod(int(line) for line in input_text.splitlines())
