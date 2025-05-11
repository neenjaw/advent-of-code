#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Solution do
  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-22/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-22/input.txt")
    input_contents
  end

  def part1(input) do
    [map_input, direction_input] =
      input
      |> String.split("\n\n", trim: true)

    map =
      map_input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {c, x} ->
          {{y, x}, c}
        end)
      end)
      |> Enum.into(%{})

    max_y =
      Enum.max_by(map, fn {{y, _x}, _c} -> y end) |> elem(0) |> elem(0) |> IO.inspect(label: "35")

    max_x =
      Enum.max_by(map, fn {{_y, x}, _c} -> x end) |> elem(0) |> elem(1) |> IO.inspect(label: "36")

    map =
      for y <- 0..max_y,
          x <- 0..max_x,
          not Map.has_key?(map, {y, x}),
          into: map,
          do: {{y, x}, " "}

    directions =
      direction_input
      |> String.trim()
      |> String.split(~r/([a-zA-Z])/, trim: true, include_captures: true)
      |> Enum.map(fn
        d when d in ~w[L R] -> d
        n -> String.to_integer(n)
      end)

    start_x = Enum.find(0..200, 0, fn x -> Map.get(map, {0, x}) == "." end)

    start_y = 0

    %{
      map: map,
      max_x: max_x,
      max_y: max_y,
      position: {start_y, start_x} |> IO.inspect(label: "start"),
      heading: 0,
      directions: directions
    }
  end

  def run(data) do
    do_run(data.directions, data.map, data.position, data.heading, data)
  end

  def do_run([], _, p = {y, x}, heading, _),
    do: {:ok, 1000 * (y + 1) + 4 * (x + 1) + heading, p, heading}

  def do_run([step | rest], map, position, heading, data) do
    case step do
      n when is_integer(n) ->
        # n |> IO.inspect(label: "move")
        # |> IO.inspect(label: "p")
        new_position = handle_move(n, map, position, heading, data)

        do_run(rest, map, new_position, heading, data)

      "L" ->
        new_heading =
          case heading do
            0 -> 3
            3 -> 2
            2 -> 1
            1 -> 0
          end

        # |> IO.inspect(label: "heading L")

        do_run(rest, map, position, new_heading, data)

      "R" ->
        new_heading =
          case heading do
            0 -> 1
            1 -> 2
            2 -> 3
            3 -> 0
          end

        # |> IO.inspect(label: "heading R")

        do_run(rest, map, position, new_heading, data)
    end
  end

  def handle_move(n, map, position, heading, data) do
    mod =
      case heading do
        0 -> {0, 1}
        1 -> {1, 0}
        2 -> {0, -1}
        3 -> {-1, 0}
      end

    move(n, map, position, position, mod, heading, data)
  end

  def move(0, _, position, _, _, _, _), do: position

  def move(n, map, p, p, mod, heading, data) do
    p_next = translate(p, mod)
    move(n, map, p, p_next, mod, heading, data)
  end

  def move(n, map, last_position, position = {y, x}, mod, heading, data) do
    Map.get(map, position) |> IO.inspect(label: "132")

    case Map.get(map, position) do
      nil ->
        wrap_p =
          case heading do
            0 -> {y, 0}
            1 -> {0, x}
            2 -> {y, data.max_x}
            3 -> {data.max_y, x}
          end
          |> IO.inspect(label: "wrap_mod")

        case Map.get(map, wrap_p) do
          "." ->
            move(n - 1, map, wrap_p, wrap_p, mod, heading, data)

          _ ->
            move(n, map, last_position, wrap_p, mod, heading, data)
        end

      "#" ->
        last_position

      "." ->
        move(n - 1, map, position, translate(position, mod), mod, heading, data)

      " " ->
        gap_p = translate(position, mod)

        case Map.get(map, gap_p) do
          "." ->
            move(n - 1, map, gap_p, gap_p, mod, heading, data)

          _ ->
            move(n, map, last_position, gap_p, mod, heading, data)
        end
    end
  end

  def translate({y, x}, {dy, dx}), do: {y + dy, x + dx}

  def overlay(map, p, dim_y, dim_x) do
    m = Map.put(map, p, "X")

    Enum.map_join(0..dim_y, "\n", fn y ->
      Enum.map_join(0..dim_x, "", fn x ->
        Map.get(m, {y, x})
      end)
    end)
    |> IO.puts()
  end
end

#
#
#

# test1 = """
#   ...
#   ..#.
#   ....

# 3
# """

# map1 = Solution.part1(test1)
# result = Solution.run(map1)
# Solution.overlay(map1.map, elem(result, 2), map1.max_y, map1.max_x)

#
#
#

Solution.read_example()
|> Solution.part1()
|> Solution.run()
|> then(fn {:ok, result, _, _} -> if result != 6032, do: raise("p1 #{result}"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> Solution.run()
|> then(fn {:ok, result, _, _} ->
  if result != 76332, do: raise("#{result}"), else: result
end)
|> IO.inspect(label: "input part 1")

# Solution.read_example()
# |> Solution.part2()
# |> then(fn {:ok, result} -> if result != 3348, do: IO.puts("#{result}"), else: result end)
# |> IO.inspect(label: "example part 2")

# Solution.read_input()
# |> Solution.part2()
# # |> then(fn {:ok, result} -> if result != 3510, do: raise("#{result}"), else: result end)
# |> IO.puts()
