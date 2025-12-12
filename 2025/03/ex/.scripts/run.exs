#!/usr/bin/env elixir

# To use packages from hex.pm, uncomment and add your dependencies:
# Mix.install([
#   {:req, "~> 0.5"}
# ])

# Load required files
parent_dir = Path.expand("..", __DIR__)
Code.require_file("utils.exs", __DIR__)
Code.require_file("solution.exs", parent_dir)

# Get input file from command line arguments (defaults to input.txt)
input_file = System.argv() |> List.first() || "input.txt"
input_path = Path.join(parent_dir, input_file)

IO.puts("\nStarting Advent of Code Solution")
IO.puts("Input file: #{input_file}")
IO.puts(String.duplicate("-", 33))

try do
  input_lines = Utils.read_input_lines(input_path)
  result = Solution.solve(input_lines)

  IO.puts(String.duplicate("-", 33))
  IO.puts("Finished successfully.")
  IO.inspect(result, label: "Overall Result")
rescue
  _e in File.Error ->
    IO.puts("\nERROR: Could not find input file '#{input_file}'.")
    IO.puts("Please make sure the file exists in the current directory.")
    System.halt(1)

  e ->
    IO.puts("\nAn unexpected error occurred:")
    IO.inspect(e)
    System.halt(1)
end
