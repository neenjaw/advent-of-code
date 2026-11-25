Code.require_file("solution.exs", __DIR__)

defmodule Runner do
  def run(input_path) do
    input = File.read!(input_path)

    IO.puts("Part 1: #{Solution.part1(input)}")

    if function_exported?(Solution, :part2, 1) do
      IO.puts("Part 2: #{Solution.part2(input)}")
    end
  end
end

case System.argv() do
  [] ->
    Runner.run(Path.join(__DIR__, "input.txt"))

  [input_path] ->
    Runner.run(input_path)

  _ ->
    IO.puts(:stderr, "Usage: elixir run.exs [input-file]")
    System.halt(1)
end
