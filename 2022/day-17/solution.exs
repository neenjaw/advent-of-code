#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Rock do
  def get_rock(:bar), do: MapSet.new([{1, 0}, {1, 1}, {1, 2}, {1, 3}])
  def get_rock(:plus), do: MapSet.new([{2, 0}, {2, 1}, {2, 2}, {1, 1}, {3, 1}])
  def get_rock(:el), do: MapSet.new([{1, 0}, {1, 1}, {1, 2}, {2, 2}, {3, 2}])
  def get_rock(:stick), do: MapSet.new([{4, 0}, {3, 0}, {2, 0}, {1, 0}])
  def get_rock(:square), do: MapSet.new([{1, 0}, {1, 1}, {2, 0}, {2, 1}])

  def translate(rock, {dy, dx}),
    do: Enum.into(rock, MapSet.new(), fn {y, x} -> {y + dy, x + dx} end)
end

defmodule Chamber do
  defstruct y_start: 3,
            x_start: 2,
            width: 7,
            settled: MapSet.new([{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}]),
            last: :square,
            current: :bar,
            rock: :bar |> Rock.get_rock() |> Rock.translate({3, 2}),
            count_settled: 0,
            floor: 0
end

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
    |> String.split("", trim: true)
    |> Stream.with_index()
    |> Stream.cycle()
    |> Stream.with_index()
  end

  # def end_at_cycle(chambers, i) do
  #   tallest = tallest_point(chambers.settled)
  #   top_row_is_bar = Enum.all?(0..6, fn x -> MapSet.member?(chambers.settled, {tallest, x}) end)

  #   chambers.current == :bar and top_row_is_bar
  # end

  def simulate(
        jet_cycle,
        end_condition_fn \\ fn chamber, _i -> chamber.count_settled == 2022 end,
        dbg \\ false
      ) do
    jet_cycle
    |> Enum.reduce_while(%Chamber{}, fn {{jet, i}, j}, chamber ->
      handled = handle(chamber, jet)

      if handled.count_settled != chamber.count_settled and dbg do
        IO.puts(to_s(chamber, true))
        IO.puts("-------------\n")
      end

      if end_condition_fn.(handled, i) do
        {:halt, handled}
      else
        {:cont, handled}
      end
    end)
  end

  def handle(chamber = %Chamber{}, jet) do
    chamber
    |> move_lateral(jet)
    |> move_down_or_settle()
  end

  def move_lateral(chamber, ">") do
    translated = Rock.translate(chamber.rock, {0, 1})
    in_bounds? = Enum.all?(translated, fn {_y, x} -> x < chamber.width end)

    if MapSet.disjoint?(chamber.settled, translated) and in_bounds? do
      %{chamber | rock: translated}
    else
      chamber
    end
  end

  def move_lateral(chamber, "<") do
    translated = Rock.translate(chamber.rock, {0, -1})
    in_bounds? = Enum.all?(chamber.rock, fn {_y, x} -> x > 0 end)

    if MapSet.disjoint?(chamber.settled, translated) and in_bounds? do
      %{chamber | rock: translated}
    else
      chamber
    end
  end

  def move_down_or_settle(chamber) do
    translated = Rock.translate(chamber.rock, {-1, 0})

    if MapSet.disjoint?(chamber.settled, translated) do
      %{chamber | rock: translated}
    else
      all_settled = MapSet.union(chamber.settled, chamber.rock)
      tp = tallest_point(all_settled)
      next_y_start = tp + 3
      next_rock = get_next_rock(chamber.current)

      %{
        chamber
        | settled: all_settled,
          y_start: next_y_start,
          last: chamber.current,
          current: next_rock,
          rock: next_rock |> Rock.get_rock() |> Rock.translate({next_y_start, chamber.x_start}),
          count_settled: chamber.count_settled + 1
      }
      |> then(fn updated ->
        cull_floor? = Enum.all?(0..6, fn x -> MapSet.member?(chamber.settled, {tp, x}) end)

        if cull_floor? do
          culled =
            Enum.filter(updated.settled, fn {y, x} -> y >= tp end) |> Enum.into(MapSet.new())

          {MapSet.size(culled), MapSet.size(updated.settled)} |> IO.inspect(label: "131")

          %{
            updated
            | floor: tp,
              settled: culled
          }
        else
          updated
        end
      end)
    end
  end

  def tallest_point(rock), do: Enum.max_by(rock, fn {y, _x} -> y end) |> elem(0)

  def get_next_rock(:bar), do: :plus
  def get_next_rock(:plus), do: :el
  def get_next_rock(:el), do: :stick
  def get_next_rock(:stick), do: :square
  def get_next_rock(:square), do: :bar

  def to_s(chamber, include_falling \\ false, numbers \\ true) do
    points =
      if include_falling do
        MapSet.union(chamber.settled, chamber.rock)
      else
        chamber.settled
      end

    y_max = tallest_point(points)

    Enum.map_join(y_max..0, "\n", fn y ->
      content =
        Enum.map_join(0..6, fn x ->
          if MapSet.member?(points, {y, x}) do
            "#"
          else
            "."
          end
        end)

      line = "|#{content}|"

      if numbers do
        "#{line} #{y}"
      else
        line
      end
    end)
  end
end

Solution.read_example()
|> Solution.parse()
|> Solution.simulate()
# |> tap(&IO.puts(Solution.to_s(&1)))
|> then(&Solution.tallest_point(&1.settled))
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.parse()
|> Solution.simulate()
# |> tap(&IO.puts(Solution.to_s(&1, false, false)))
|> then(&Solution.tallest_point(&1.settled))
|> IO.inspect(label: "input part 2")

Solution.read_input()
|> Solution.parse()
|> Solution.simulate()
# |> tap(&IO.puts(Solution.to_s(&1)))
# |> then(&Solution.tallest_point(&1.settled))
|> then(&{Solution.tallest_point(&1.settled), &1.count_settled})
|> IO.inspect(label: "example part 1")

# input_contents
# |> Solution.parse()
# |> Solution.simulate_pachyderm()
# |> then(fn sol -> {sol.stops, Solution.score(sol)} end)
# |> IO.inspect(label: "input part 2")

# AA, DD, BB, JJ, HH, EE, CC
