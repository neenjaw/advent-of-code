import aoc_gleam/solution
import gleam/option.{Some}
import gleeunit
import simplifile

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn part1_sample_test() {
  let assert Ok(input) = simplifile.read(from: "samples/part1.txt")
  assert solution.part1(input) == "3"
}

pub fn part2_sample_test() {
  let assert Ok(input) = simplifile.read(from: "samples/part2.txt")
  assert solution.part2(input) == Some("10")
}
