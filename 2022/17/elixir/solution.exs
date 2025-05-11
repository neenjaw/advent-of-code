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

defmodule State do
  defstruct current_rock_type: :bar,
            current_rock_index: 0,
            x_start: 2,
            width: 7,
            settled: MapSet.new([{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}]),
            rock: :bar |> Rock.get_rock() |> Rock.translate({3, 2}),
            settled_rock_count: 0,
            floor: 0,
            meta: %{
              cycle_has_started: false,
              loop_start_found: false,
              rock_index_on_cycle_start: -1,
              jet_index_on_cycle_start: -1,
              settled_rock_count_on_cycle_start: -1,
              tower_height_on_cycle_start: -1,
              cycle_added: false
            }
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

  def simulate(
        jet_cycle,
        up_to \\ 2022,
        dbg \\ false
      ) do
    jet_cycle
    |> Enum.reduce_while(%State{}, fn {{jet, jet_index}, _counter}, state ->
      handle(state, jet)
      |> tap(fn next_state ->
        if state.settled_rock_count != next_state.settled_rock_count and dbg do
          IO.puts(to_s(next_state, true))
          IO.puts("-------------\n")
        end
      end)
      |> detect_cycle(jet_index)
      |> chomp_settled_rocks()
      |> then(fn next_state ->
        if next_state.settled_rock_count == up_to do
          {:halt, next_state}
        else
          {:cont, next_state}
        end
      end)
    end)
  end

  def detect_cycle(state, jet_index) do
    if not state.meta.cycle_added do
      state
      |> then(&check_cycle_start(&1, jet_index))
      |> then(&check_loop_start(&1, jet_index))
      |> then(&check_loop_end(&1, jet_index))
    else
      state
    end
  end

  def check_cycle_start(state, _jet_index) do
    if state.settled_rock_count > 10000 and not state.meta.cycle_has_started do
      %{state | meta: %{state.meta | cycle_has_started: true}}
    else
      state
    end
  end

  def check_loop_start(state, jet_index) do
    if state.meta.cycle_has_started and not state.meta.loop_start_found do
      %{
        state
        | meta: %{
            state.meta
            | loop_start_found: true,
              jet_index_on_cycle_start: jet_index,
              rock_index_on_cycle_start: state.current_rock_index,
              tower_height_on_cycle_start: tallest_point(state.settled),
              settled_rock_count_on_cycle_start: state.settled_rock_count
          }
      }
    else
      state
    end
  end

  def check_loop_end(state, jet_index) do
    if state.meta.loop_start_found and
         state.settled_rock_count != state.meta.settled_rock_count_on_cycle_start and
         state.current_rock_index == state.meta.rock_index_on_cycle_start and
         jet_index == state.meta.jet_index_on_cycle_start do
      IO.puts("Cycle found")

      current_tower_height = tallest_point(state.settled)

      cycle_tower_height = current_tower_height - state.meta.tower_height_on_cycle_start

      cycle_rocks_added_to_count =
        state.settled_rock_count - state.meta.settled_rock_count_on_cycle_start

      cycles_to_add =
        div(1_000_000_000_000 - state.settled_rock_count, cycle_rocks_added_to_count)

      adjusted_rock_count = state.settled_rock_count + cycles_to_add * cycle_rocks_added_to_count
      adjusted_tower_height = current_tower_height + cycles_to_add * cycle_tower_height
      tower_height_difference = adjusted_tower_height - current_tower_height

      [
        current_tower_height: current_tower_height,
        cycle_tower_height: cycle_tower_height,
        cycle_rocks_added_to_count: cycle_rocks_added_to_count,
        cycles_to_add: cycles_to_add,
        adjusted_rock_count: adjusted_rock_count,
        adjusted_tower_height: adjusted_tower_height,
        tower_height_difference: tower_height_difference
      ]
      |> IO.inspect(label: "cycle details:")

      adjusted_settled = Rock.translate(state.settled, {tower_height_difference, 0})
      adjusted_rock = Rock.translate(state.rock, {tower_height_difference, 0})

      %{
        state
        | rock: adjusted_rock,
          settled: adjusted_settled,
          settled_rock_count: adjusted_rock_count,
          meta: %{state.meta | cycle_added: true}
      }
    else
      state
    end
  end

  def chomp_settled_rocks(state) do
    if div(state.settled_rock_count, 2000) == 0 and state.settled_rock_count > 100 do
      do_chomp_settled_rocks(state)
    else
      state
    end
  end

  def do_chomp_settled_rocks(state) do
    cut_off = tallest_point(state.settled) - 100

    cut_off_settled =
      state.settled |> Enum.filter(fn {y, _x} -> y > cut_off end) |> Enum.into(MapSet.new())

    %{state | settled: cut_off_settled}
  end

  def handle(state = %State{}, jet) do
    state
    |> move_lateral(jet)
    |> move_down_or_settle()
  end

  def move_lateral(state, ">") do
    translated = Rock.translate(state.rock, {0, 1})
    in_bounds? = Enum.all?(translated, fn {_y, x} -> x < state.width end)

    if MapSet.disjoint?(state.settled, translated) and in_bounds? do
      %{state | rock: translated}
    else
      state
    end
  end

  def move_lateral(state, "<") do
    translated = Rock.translate(state.rock, {0, -1})
    in_bounds? = Enum.all?(state.rock, fn {_y, x} -> x > 0 end)

    if MapSet.disjoint?(state.settled, translated) and in_bounds? do
      %{state | rock: translated}
    else
      state
    end
  end

  def move_down_or_settle(state) do
    translated = Rock.translate(state.rock, {-1, 0})

    if MapSet.disjoint?(state.settled, translated) do
      %{state | rock: translated}
    else
      all_settled = MapSet.union(state.settled, state.rock)
      tp = tallest_point(all_settled)
      {next_rock_type, next_rock_index} = get_next_rock(state.current_rock_type)

      %{
        state
        | settled: all_settled,
          current_rock_type: next_rock_type,
          current_rock_index: next_rock_index,
          rock:
            next_rock_type
            |> Rock.get_rock()
            |> Rock.translate({tp + 3, state.x_start}),
          settled_rock_count: state.settled_rock_count + 1
      }
    end
  end

  def tallest_point(rock), do: Enum.max_by(rock, fn {y, _x} -> y end) |> elem(0)

  def get_next_rock(:bar), do: {:plus, 1}
  def get_next_rock(:plus), do: {:el, 2}
  def get_next_rock(:el), do: {:stick, 3}
  def get_next_rock(:stick), do: {:square, 4}
  def get_next_rock(:square), do: {:bar, 0}

  def to_s(state, include_falling \\ false, numbers \\ true, amount \\ nil) do
    points =
      if include_falling do
        MapSet.union(state.settled, state.rock)
      else
        state.settled
      end

    y_max = tallest_point(points)

    y_min =
      if amount do
        y_max - amount
      else
        0
      end

    Enum.map_join(y_max..y_min, "\n", fn y ->
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
|> then(&Solution.tallest_point(&1.settled))
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.parse()
|> Solution.simulate()
|> then(&Solution.tallest_point(&1.settled))
|> IO.inspect(label: "input part 1")

Solution.read_input()
|> Solution.parse()
|> Solution.simulate(1_000_000_000_000)
|> then(&{Solution.tallest_point(&1.settled), &1.settled_rock_count})
|> IO.inspect(label: "input part 2")
