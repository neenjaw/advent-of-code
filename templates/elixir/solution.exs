defmodule Solution do
  @moduledoc """
  Advent of Code solution for this day.
  """

  def solve(input_lines) do
    # Part 1 Solution
    part1 = part1(input_lines)

    # Part 2 Solution (Placeholder)
    part2 = part2(input_lines)

    IO.puts("""

    Solving with #{length(input_lines)} lines of input.
    Part 1 Result: #{part1}
    Part 2 Result: #{part2}

    """)

    %{part1: part1, part2: part2}
  end

  defp part1(input_lines) do
    # Example: Sum the length of all lines
    Enum.reduce(input_lines, 0, fn line, acc -> acc + String.length(line) end)
  end

  defp part2(_input_lines) do
    "TBD"
  end
end
