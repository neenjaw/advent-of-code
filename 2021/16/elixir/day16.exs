defmodule Aimer do
  @type position :: {x :: integer(), y :: integer()}
  @type velocity :: {x_velocity :: integer(), y_velocity :: integer()}
  @type probe :: {position(), velocity()}

  @start {0, 0}

  def geometric_series_sum(n) do
    div(n * (n + 1), 2)
  end

  def find_min_x(goal) when is_struct(goal, Range) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(&{&1, geometric_series_sum(&1)})
    |> Stream.drop_while(&(&1 |> elem(1) |> Kernel.<(goal.first)))
    |> Stream.take_while(&(&1 |> elem(1) |> Kernel.<=(goal.last)))
    |> Enum.map(&elem(&1, 0))
  end

  def find_max_y(goal, x_velocity_options) do
    x_velocity_options
    |> Enum.map(fn x_velocity ->
      Stream.iterate(1, &(&1 + 1))
      |> Stream.map(&simulate(&1, &1, x_velocity, goal))
      |> Stream.drop_while(&(!&1))
      |> Stream.take_while(& &1)
      |> Enum.max()
    end)
    |> Enum.max()
  end

  def simulate(y_start_v, y_v, steps, goal, y \\ 0, max \\ 0)

  def simulate(y_start_v, y_v, steps, goal, y, max) when steps > 0 do
    simulate(y_start_v, y_v - 1, steps - 1, goal, y + y_v, if(y > max, do: y, else: max))
  end

  def simulate(y_start_v, y_v, step, goal, y, max) do
    # IO.inspect(binding(), label: "40")

    cond do
      y in goal ->
        {y_start_v, max}

      y > goal.last ->
        simulate(y_start_v, y_v - 1, 0, goal, y + y_v, if(y > max, do: y, else: max))

      true ->
        nil
    end
  end
end

target_areas = [
  {{20..30, -10..-5}, {6, 9}},
  {{265..287, -58..103}, :unknown}
]

target_areas
|> Enum.at(1)
|> elem(0)
|> elem(0)
|> Aimer.find_min_x()
|> IO.inspect(label: "29")

target_areas
|> Enum.at(1)
|> elem(0)
|> elem(1)
|> Aimer.find_max_y([23])
|> IO.inspect(label: "30")

"""
     1   2  3 4+
      1    2   3  4 5+
...............#..#............
...........#........#..........
...............................
......#..............#.........
...............................
...............................
S....................#.........
...............................
...............................
...............................
.....................#.........
....................TTTTTTTTTTT
....................TTTTTTTTTTT
....................TTTTTTTTTTT
....................TTTTTTTTTTT
....................T#TTTTTTTTT
....................TTTTTTTTTTT
"""
