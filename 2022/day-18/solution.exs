#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Solution do
  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-17/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-17/input.txt")
    input_contents
  end

  def parse(input) do
    input
  end
end

Solution.read_example()
|> Solution.parse()
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.parse()
|> IO.inspect(label: "input part 1")

Solution.read_input()
|> Solution.parse()
|> IO.inspect(label: "input part 2")
