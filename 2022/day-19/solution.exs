#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Solution do
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
    |> Enum.map(&to_blueprint/1)
    |> solve()
  end

  def to_blueprint(line) do
    pattern =
      ~r/^[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+$/

    [blueprint, oo, co, obo, oc, go, gob] =
      Regex.scan(pattern, line)
      |> hd()
      |> tl()
      |> Enum.map(&String.to_integer/1)

    %{
      label: blueprint,
      costs: %{
        ore: %{ore: oo, clay: 0, obsidian: 0, geode: 0},
        clay: %{ore: co, clay: 0, obsidian: 0, geode: 0},
        obsidian: %{ore: obo, clay: oc, obsidian: 0, geode: 0},
        geode: %{ore: go, obsidian: gob, clay: 0, geode: 0}
      },
      restrictions: %{
        next: [],
        future: []
      },
      robots: %{
        ore: 1,
        clay: 0,
        obsidian: 0,
        geode: 0
      },
      time: 0,
      bank: %{
        ore: 0,
        clay: 0,
        obsidian: 0,
        geode: 0
      }
    }
  end

  def solve(blueprints) do
    blueprints
    |> Enum.map(&do_solve/1)
    |> Enum.sum()
  end

  def do_solve(state) do
    IO.puts("label: 51")

    state
    |> simulate(fn state -> state.time == 24 end)
    |> then(&(elem(&1, 0) * state.label))
    |> tap(&IO.inspect(&1))
  end

  def get_state_key(state) do
    {
      state.time,
      state.bank.ore,
      state.bank.clay,
      state.bank.obsidian,
      state.robots.ore,
      state.robots.clay,
      state.robots.obsidian
    }
  end

  def simulate(state, done_fn, memo \\ %{}) do
    cond do
      done_fn.(state) ->
        # IO.puts("label: done")

        {state.bank.geode, Map.put(memo, get_state_key(state), state.bank.geode)}

      Map.get(memo, get_state_key(state), -1) >= state.bank.geode ->
        # IO.puts("label: use memo")
        {Map.get(memo, get_state_key(state)), memo}

      true ->
        # IO.puts("label: get memo")
        {result, result_memo} = do_simulate(state, done_fn, memo)
        {result, Map.put(result_memo, get_state_key(state), result)}
    end
  end

  def do_simulate(state, done_fn, memo) do
    state
    |> choices()
    |> Enum.reduce({state.bank.geode, memo}, fn {choice, next_state}, {best_result, memo_acc} ->
      {result, result_memo} =
        case choice do
          :build_ore ->
            next_state
            |> add_robot(:ore)

          :build_clay ->
            next_state
            |> add_robot(:clay)

          :build_obsidian ->
            next_state
            |> add_robot(:obsidian)

          :build_geode ->
            next_state
            |> add_robot(:geode)

          :nothing ->
            next_state
        end
        |> then(fn choice_state ->
          choice_state
          |> tick_state()
          |> simulate(done_fn, memo_acc)
        end)

      {Enum.max([best_result, result]), result_memo}
    end)
  end

  def tick_state(state) do
    %{
      state
      | time: state.time + 1,
        bank:
          Enum.into(state.bank, %{}, fn {supply_type, amount} ->
            {supply_type, amount + state.robots[supply_type]}
          end)
    }
  end

  def add_robot(state, robot_type) do
    %{
      state
      | robots: %{state.robots | robot_type => state.robots[robot_type] + 1},
        bank:
          Enum.into(state.bank, %{}, fn {supply_type, amount} ->
            {supply_type, amount - state.costs[robot_type][supply_type]}
          end)
    }
  end

  def choices(state) do
    all_choices = [:build_geode, :build_obsidian, :build_clay, :build_ore, :nothing]
    possible_choices = all_choices -- state.restrictions.next -- state.restrictions.future

    possible_choices
    |> Enum.filter(fn
      :build_ore ->
        has_resources(state, :ore)

      :build_clay ->
        has_resources(state, :clay)

      :build_obsidian ->
        has_resources(state, :obsidian)

      :build_geode ->
        has_resources(state, :geode)

      :nothing ->
        not has_resources(state, :geode)
    end)
    |> Enum.map(fn
      :nothing ->
        next_restrictions =
          []
          |> then(fn restricted ->
            if has_resources(state, :ore),
              do: [:build_ore | restricted],
              else: restricted
          end)
          |> then(fn restricted ->
            if has_resources(state, :clay),
              do: [:build_clay | restricted],
              else: restricted
          end)
          |> then(fn restricted ->
            if has_resources(state, :obsidian),
              do: [:build_obsidian | restricted],
              else: restricted
          end)

        {:nothing,
         %{
           state
           | restrictions: %{
               state.restrictions
               | next: next_restrictions
             }
         }}

      :build_ore ->
        restricted_in_future? =
          :build_ore not in state.restrictions.future and
            state.robots.ore + 1 ==
              Enum.max([
                state.costs.ore.ore,
                state.costs.clay.ore,
                state.costs.obsidian.ore,
                state.costs.geode.ore
              ])

        future_restrictions =
          if restricted_in_future? do
            [:build_ore | state.restrictions.future] |> Enum.uniq()
          else
            state.restrictions.future
          end

        {:build_ore,
         %{
           state
           | restrictions: %{
               state.restrictions
               | next: [],
                 future: future_restrictions
             }
         }}

      :build_clay ->
        restricted_in_future? =
          :build_clay not in state.restrictions.future and
            state.robots.clay + 1 ==
              Enum.max([
                state.costs.ore.clay,
                state.costs.clay.clay,
                state.costs.obsidian.clay,
                state.costs.geode.clay
              ])

        future_restrictions =
          if restricted_in_future? do
            [:build_clay | state.restrictions.future] |> Enum.uniq()
          else
            state.restrictions.future
          end

        {:build_clay,
         %{
           state
           | restrictions: %{
               state.restrictions
               | next: [],
                 future: future_restrictions
             }
         }}

      :build_obsidian ->
        restricted_in_future? =
          :build_obsidian not in state.restrictions.future and
            state.robots.obsidian + 1 ==
              Enum.max([
                state.costs.ore.obsidian,
                state.costs.clay.obsidian,
                state.costs.obsidian.obsidian,
                state.costs.geode.obsidian
              ])

        future_restrictions =
          if restricted_in_future? do
            [:build_obsidian | state.restrictions.future] |> Enum.uniq()
          else
            state.restrictions.future
          end

        {:build_obsidian,
         %{
           state
           | restrictions: %{
               state.restrictions
               | next: [],
                 future: future_restrictions
             }
         }}

      choice ->
        {choice, state}
    end)
  end

  def has_resources(state, type) do
    Enum.all?(state.costs[type], fn {supply_type, cost_amount} ->
      state.bank[supply_type] >= cost_amount
    end)
  end
end

Solution.read_example()
|> Solution.part1()
|> then(fn result -> if result != 33, do: raise("#{result}!"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> then(fn result -> if result != 58, do: raise("#{result}!"), else: result end)
|> IO.inspect(label: "input part 1")

# Solution.read_example()
# |> Solution.part2()
# |> then(fn result -> if result != 58, do: raise("#{result}!"), else: result end)
# |> IO.inspect(label: "example part 2")

# Solution.read_input()
# |> Solution.part2()
# |> then(fn result -> if result != 2018, do: raise("#{result}!"), else: result end)
# |> IO.inspect(label: "input part 2")
