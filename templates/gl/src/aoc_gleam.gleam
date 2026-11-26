import aoc_gleam/solution
import argv
import gleam/io
import gleam/option.{None, Some}
import simplifile

pub fn main() -> Nil {
  case argv.load().arguments {
    [] -> run("input.txt")
    [input_path] -> run(input_path)
    _ -> {
      io.println_error("Usage: gleam run [input-file]")
      panic as "Invalid command-line arguments"
    }
  }
}

fn run(input_path: String) -> Nil {
  case simplifile.read(from: input_path) {
    Ok(input) -> print_answers(input)
    Error(error) -> {
      io.println_error(
        "Could not read "
        <> input_path
        <> ": "
        <> simplifile.describe_error(error),
      )
      panic as "Could not read input file"
    }
  }
}

fn print_answers(input: String) -> Nil {
  io.println("Part 1: " <> solution.part1(input))

  case solution.part2(input) {
    Some(answer) -> io.println("Part 2: " <> answer)
    None -> Nil
  }
}
