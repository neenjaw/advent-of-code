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
    |> solve(24)
    |> Enum.map(fn {q, l} -> q * l end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.take(3)
    |> Enum.map(&to_blueprint/1)
    |> solve(32)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(&*/2)
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

  def solve(blueprints, mins) do
    Enum.map(blueprints, &do_solve(&1, mins))
  end

  def do_solve(state, mins) do
    state
    |> simulate(fn state -> state.time == mins end)
    |> then(&{&1.bank.geode, &1.label})
    |> tap(fn _ -> IO.write(".") end)
  end

  def simulate(state, done_fn) do
    do_simulate([state], done_fn)
  end

  def do_simulate(states, done_fn) do
    next_states = Enum.flat_map(states, &branch/1)
    max_geode_state = Enum.max_by(next_states, & &1.bank.geode)

    if done_fn.(hd(next_states)) do
      max_geode_state
    else
      next_states
      |> Enum.sort_by(
        &Enum.zip(
          [&1.bank.geode, &1.bank.obsidian, &1.bank.clay, &1.bank.clay],
          [&1.robots.geode, &1.robots.obsidian, &1.robots.clay, &1.robots.clay]
        ),
        :desc
      )
      |> Enum.take(5000)
      |> do_simulate(done_fn)
    end
  end

  def branch(state) do
    [:geode, :obsidian, :clay, :ore, :nothing]
    |> Enum.filter(fn
      :ore ->
        has_resources(state, :ore)

      :clay ->
        has_resources(state, :clay)

      :obsidian ->
        has_resources(state, :obsidian)

      :geode ->
        has_resources(state, :geode)

      :nothing ->
        not has_resources(state, :geode)
    end)
    |> Enum.map(fn
      :nothing -> tick_state(state)
      type -> state |> tick_state() |> add_robot(type)
    end)
  end

  def has_resources(state, type) do
    Enum.all?(state.costs[type], fn {supply_type, cost_amount} ->
      state.bank[supply_type] >= cost_amount
    end)
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
end

Solution.read_example()
|> Solution.part1()
|> then(fn result -> if result != 33, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> then(fn result -> if result != 1199, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "input part 1")

Solution.read_example()
|> Solution.part2()
|> then(fn result -> if result != 3348, do: IO.puts("#{result}"), else: result end)
|> IO.inspect(label: "example part 2")

Solution.read_input()
|> Solution.part2()
|> then(fn result -> if result != 3510, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "input part 2")
