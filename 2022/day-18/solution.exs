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

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.map(fn line -> Enum.map(String.split(line, ",", trim: true), &String.to_integer/1) end)
    |> Enum.map(&List.to_tuple(&1))
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

  def count_z_external_faces(faces) do
    for x <- 0..19,
        y <- 0..19,
        Enum.any?(faces, fn
          {:z, {^x, ^y, _}} -> true
          _ -> false
        end) do
      2
    end
    |> Enum.sum()
  end

  def count_y_external_faces(faces) do
    for x <- 0..19,
        z <- 0..19,
        Enum.any?(faces, fn
          {:y, {^x, _, ^z}} -> true
          _ -> false
        end) do
      2
    end
    |> Enum.sum()
  end

  def count_x_external_faces(faces) do
    for z <- 0..19,
        y <- 0..19,
        Enum.any?(faces, fn
          {:x, {_, ^y, ^z}} -> true
          _ -> false
        end) do
      2
    end
    |> Enum.sum()
  end

  def part2(faces) do
    [
      &count_x_external_faces/1,
      &count_z_external_faces/1,
      &count_y_external_faces/1
    ]
    |> Enum.map(& &1.(faces))
    |> Enum.sum()
  end
end

Solution.read_example()
|> Solution.parse()
|> MapSet.size()
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.parse()
|> MapSet.size()
|> IO.inspect(label: "input part 1")

Solution.read_example()
|> Solution.parse()
|> Solution.part2()
|> IO.inspect(label: "example part 2")

# Solution.read_input()
# |> Solution.parse()
# |> IO.inspect(label: "input part 2")
