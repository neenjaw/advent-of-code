import gleam/int
import gleam/list
import gleam/option.{type Option, Some}
import gleam/string

pub fn part1(input: String) -> String {
  input
  |> string.split("\n")
  |> list.filter(fn(line) { line != "" })
  |> list.length
  |> int.to_string
}

pub fn part2(input: String) -> Option(String) {
  input
  |> string.length
  |> int.to_string
  |> Some
}
