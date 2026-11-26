defmodule Solution do
  @moduledoc """
  Puzzle logic for this day. Functions receive the raw input text.
  """

  def part1(input) do
    input
    |> lines()
    |> Enum.reduce(0, fn line, total -> total + String.length(line) end)
  end

  def part2(input) do
    input
    |> lines()
    |> length()
  end

  defp lines(input), do: String.split(input, "\n", trim: true)
end
