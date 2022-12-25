#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Solution do
  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-23/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-23/input.txt")
    input_contents
  end
end

Solution.read_example()
|> Solution.part1()
|> then(fn r -> if elem(r, 1) != 6032, do: raise("p1 #{result}"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> then(fn r -> if elem(r, 1) != 76332, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "input part 1")

# Solution.read_example()
# |> Solution.part2()
# |> then(fn r -> if elem(r, 1) != 3348, do: IO.puts("#{result}"), else: result end)
# |> IO.inspect(label: "example part 2")

# Solution.read_input()
# |> Solution.part2()
# # |> then(fn r -> if elem(r, 1) != 3510, do: raise("#{result}"), else: result end)
# |> IO.puts()
