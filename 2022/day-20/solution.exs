#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Solution do
  @important [
    1000,
    2000,
    3000
  ]

  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-19/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-19/input.txt")
    input_contents
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> reorder()
    |> collect(@important)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

Solution.read_example()
|> Solution.part1()
|> then(fn result -> if result != 33, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> then(fn result -> if result != 1199, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "input part 1")

Solution.read_example()
|> Solution.part2()
|> then(fn result -> if result != 3348, do: IO.puts("#{result}"), else: result end)
|> IO.inspect(label: "example part 2")

Solution.read_input()
|> Solution.part2()
|> then(fn result -> if result != 3510, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "input part 2")
