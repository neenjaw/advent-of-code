#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Solution do
  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-18/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-18/input.txt")
    input_contents
  end

  def part1(input) do
    parse_to_tuples(input)
    |> Enum.map(&explode_faces/1)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {faces, i}, acc ->
      # IO.inspect(binding(), label: "23")

      diff_a = MapSet.difference(faces, acc)
      diff_b = MapSet.difference(acc, faces)

      union = MapSet.union(diff_a, diff_b)
      # |> IO.inspect(label: "29")

      # if i == 1 do
      #   raise "!"
      # end

      union
    end)
  end

  def parse_to_tuples(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.map(fn line -> Enum.map(String.split(line, ",", trim: true), &String.to_integer/1) end)
    |> Enum.map(&List.to_tuple(&1))
  end

  def explode_faces({x, y, z}) do
    MapSet.new([
      {:x, {x, y, z}},
      {:x, {x + 1, y, z}},
      {:y, {x, y, z}},
      {:y, {x, y + 1, z}},
      {:z, {x, y, z}},
      {:z, {x, y, z + 1}}
    ])
  end

  def part2(input) do
    blocks = parse_to_tuples(input) |> MapSet.new()

    buffer = fn {min, max} -> {min - 1, max + 1} end

    {min_x, max_x} = blocks |> Enum.map(&elem(&1, 0)) |> Enum.min_max() |> buffer.()
    {min_y, max_y} = blocks |> Enum.map(&elem(&1, 1)) |> Enum.min_max() |> buffer.()
    {min_z, max_z} = blocks |> Enum.map(&elem(&1, 2)) |> Enum.min_max() |> buffer.()

    starting_block = {min_x, min_y, min_z}
    shell = dfs(starting_block, blocks, MapSet.new(), min_x..max_x, min_y..max_y, min_z..max_z)

    blocks
    |> Enum.map(fn block -> Enum.count(get_options(block), &MapSet.member?(shell, &1)) end)
    |> Enum.sum()
  end

  def dfs(block, lava_blocks, visited, x_range, y_range, z_range) do
    get_options(block)
    |> Enum.reduce(visited, fn option, visited_acc ->
      if not MapSet.member?(lava_blocks, option) and
           not MapSet.member?(visited_acc, option) and
           in_bounds?(block, x_range, y_range, z_range) do
        dfs(option, lava_blocks, MapSet.put(visited_acc, option), x_range, y_range, z_range)
      else
        visited_acc
      end
    end)
  end

  def in_bounds?({x, y, z}, x_range, y_range, z_range) do
    x in x_range and y in y_range and z in z_range
  end

  def get_options({x, y, z}) do
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z - 1},
      {x, y, z + 1}
    ]
  end
end

Solution.read_example()
|> Solution.part1()
|> MapSet.size()
|> then(fn result -> if result != 64, do: raise("!"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> MapSet.size()
|> then(fn result -> if result != 3412, do: raise("!"), else: result end)
|> IO.inspect(label: "input part 1")

Solution.read_example()
|> Solution.part2()
|> then(fn result -> if result != 58, do: raise("#{result}!"), else: result end)
|> IO.inspect(label: "example part 2")

Solution.read_input()
|> Solution.part2()
|> then(fn result -> if result != 2018, do: raise("#{result}!"), else: result end)
|> IO.inspect(label: "input part 2")
