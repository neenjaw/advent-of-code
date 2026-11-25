import unittest
from pathlib import Path

from solution import part1, part2


SAMPLES = Path(__file__).parents[1] / "samples"


class SolutionTests(unittest.TestCase):
    def test_part1(self) -> None:
        input_text = (SAMPLES / "part1.txt").read_text()
        self.assertEqual(part1(input_text), 6)

    def test_part2(self) -> None:
        input_text = (SAMPLES / "part2.txt").read_text()
        self.assertEqual(part2(input_text), 24)


if __name__ == "__main__":
    unittest.main()
