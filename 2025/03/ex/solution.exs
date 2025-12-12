defmodule Solution do
  @moduledoc """
  Advent of Code solution for this day.

  - batteries are in banks (row)
  - need to find two batteries in a bank (two largest numbers)
  """

  def part1(input_lines) do
    input_lines = String.split(input_lines, "\n", trim: true)
    Enum.reduce(input_lines, 0, &handle_line/2)
  end

  defp handle_line(line, acc) do
    [a, b | rest] = String.to_charlist(line)

    bank_joltage =
      rest
      |> Enum.reduce({a, b}, fn battery, {l, r} ->
        [
          {l, battery},
          {r, battery},
          {l, r}
        ]
        |> Enum.max_by(fn {l, r} -> l * 10 + r end)
      end)
      |> then(fn {l, r} ->
        [l, r]
        |> to_string()
        |> String.to_integer()
      end)

    acc + bank_joltage
  end

  def part2(input_lines) do
    input_lines
    |> String.split("\n", trim: true)
    |> Enum.map(&handle_line2/1)
    |> Enum.sum()
  end

  defp handle_line2(line) do
    bank =
      line
      |> String.to_charlist()
      |> Enum.with_index()

    {first_twelve, rest} = Enum.split(bank, 12)

    rest
    |> Enum.reduce(first_twelve, fn battery, twelve ->
      options =
        0..11
        |> Enum.map(fn i ->
          twelve
          |> List.delete_at(i)
          |> List.insert_at(11, battery)
        end)

      options = [twelve | options]

      Enum.max_by(options, fn x -> bank_value(x) end)
    end)
    |> then(fn result -> bank_value(result) end)
  end

  def bank_value(bank) do
    bank
    |> Enum.reverse()
    |> Enum.reduce({0, 0}, fn {v, _}, {i, sum} ->
      {i + 1, sum + (v - 48) * Integer.pow(10, i)}
    end)
    |> then(fn {_i, sum} -> sum end)
  end
end
