defmodule Solution do
  @moduledoc """
  Advent of Code solution for this day.
  """

  def solve(input) do
    # Part 1 Solution
    part1 = part1(input)

    # Part 2 Solution (Placeholder)
    part2 = part2(input)

    IO.puts("""

    Solving with #{length(input)} lines of input.
    Part 1 Result: #{part1}
    Part 2 Result: #{part2}

    """)

    %{part1: part1, part2: part2}
  end

  defp part1(input) do
    # Example: Sum the length of all lines
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn line, acc -> acc + String.length(line) end)
  end

  defp part2(_input) do
    "TBD"
  end
end
