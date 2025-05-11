#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

{:ok, ex_contents} = File.read("./2022/day-15/example.txt")
{:ok, input_contents} = File.read("./2022/day-15/input.txt")

defmodule Solution do
  def parse_to_rules(contents, goal) do
    contents
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&to_rule(&1, goal))
    |> Enum.sort_by(& &1.min_x, :asc)
  end

  def to_rule(line, target) do
    parser = ~r{^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$}

    [sx, sy, bx, by] =
      Regex.scan(parser, line)
      |> hd()
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)

    range = get_sensor_coverage({sx, sy}, {bx, by})

    %{
      s_rule: fn x ->
        diff = range - abs(target - sy)

        sy - range <= target and target <= sy + range and sx - diff <= x and x <= sx + diff
      end,
      b_rule: fn x -> by != target or x != bx end,
      sx_rule: fn x, y ->
        diff = range - abs(y - sy)
        sy - range <= y and y <= sy + range and sx - diff <= x and x <= sx + diff
      end,
      skip_fn: fn x, y ->
        diff = range - abs(y - sy)
        sx + diff + 1
      end,
      min_x: sx - range,
      max_x: sx + range
    }
  end

  def get_sensor_coverage({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def apply_rules(rules, adj \\ 0) do
    min_x = Enum.min_by(rules, &Map.get(&1, :min_x)).min_x
    max_x = Enum.max_by(rules, &Map.get(&1, :max_x)).max_x

    Enum.count(min_x..max_x, fn x ->
      Enum.any?(rules, & &1.s_rule.(x)) and Enum.all?(rules, & &1.b_rule.(x))
    end)
    |> then(&(&1 - adj))
  end

  def apply_more_rules(rules, bounds \\ 0..20) do
    trace(rules, bounds, bounds.first, bounds.first)
  end

  def trace(rules, bounds, x, y) do
    cond do
      x > bounds.last ->
        trace(rules, bounds, bounds.first, y + 1)

      y > bounds.last ->
        {:out_of_grid, x, y}

      true ->
        case Enum.find(rules, & &1.sx_rule.(x, y)) do
          nil -> {:found, x, y}
          rule -> trace(rules, bounds, rule.skip_fn.(x, y), y)
        end
    end
  end

  def product({:found, x, y}), do: x * 4_000_000 + y
end

ex_contents
|> Solution.parse_to_rules(10)
|> Solution.apply_rules()
|> IO.inspect(label: "example part 1")

ex_contents
|> Solution.parse_to_rules(10)
|> Solution.apply_more_rules(0..20)
|> Solution.product()
|> IO.inspect(label: "example part 2")

input_contents
|> Solution.parse_to_rules(2_000_000)
|> Solution.apply_rules()
|> IO.inspect(label: "input part 1")

input_contents
|> Solution.parse_to_rules(2_000_000)
|> Solution.apply_more_rules(0..4_000_000)
|> Solution.product()
|> IO.inspect(label: "input part 2")
