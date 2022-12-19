#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

{:ok, ex_contents} = File.read("./2022/day-16/example.txt")
{:ok, input_contents} = File.read("./2022/day-16/input.txt")

defmodule Solution do
  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-16/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-16/input.txt")
    input_contents
  end

  def parse(contents) do
    contents
    |> String.split(~r{\n}, trim: true)
    |> Enum.reduce({Graph.new(), %{}}, &do_parse(&1, &2))
  end

  def do_parse(line, {graph, vertex_metadata}) do
    parser =
      ~r/^Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? (([A-Z]{2}(, )?)+)$/

    [_, node, flow, connections | _] =
      Regex.scan(parser, line)
      |> hd()

    graph =
      connections
      |> String.split(~r{, }, trim: true)
      |> Enum.reduce(graph, &Graph.add_edge(&2, node, &1, weight: 1))

    vertex_metadata = Map.put(vertex_metadata, node, String.to_integer(flow))

    {graph, vertex_metadata}
  end

  def simulate({graph, vertex_metadata}, time \\ 30) do
    state = %{
      total_time: time,
      time_remaining: time,
      graph: graph,
      vertices: vertex_metadata,
      opened: %{},
      steps_taken: [{:start, "AA", 30}],
      stops: ["AA"]
    }

    do_simulate(state)
  end

  def do_simulate(
        state = %{
          graph: graph,
          vertices: vs,
          opened: open_vs,
          steps_taken: steps = [last_step | _],
          time_remaining: time_remaining
        }
      ) do
    case last_step do
      {:start, current, _} ->
        do_simulate(%{
          state
          | steps_taken: [{:look_for_next, current} | steps]
        })

      {:open, current} ->
        do_simulate(%{
          state
          | steps_taken: [{:look_for_next, current} | steps]
        })

      {:look_for_next, current} ->
        case find_next_moves(graph, current, vs, open_vs, time_remaining) do
          [] ->
            state

          moves ->
            moves
            |> Enum.map(fn {goal, path, cost} ->
              %{
                state
                | time_remaining: time_remaining - cost,
                  steps_taken: [{:move, goal, path, cost, time_remaining - cost} | steps],
                  stops: state.stops ++ [goal]
              }
              |> do_simulate()
            end)
            |> Enum.max_by(&score/1)
        end

      {:move, current, _, _, _} ->
        if not Map.has_key?(open_vs, current) do
          %{
            state
            | time_remaining: time_remaining - 1,
              steps_taken: [{:open, current} | steps],
              opened: Map.put(open_vs, current, time_remaining - 1)
          }
          |> do_simulate()
        end
    end
  end

  def find_next_moves(graph, current, vs, open_vs, time_remaining) do
    visited_vs = Map.keys(open_vs)

    vs
    |> Map.keys()
    |> Enum.filter(&(&1 != current and &1 not in visited_vs and Map.get(vs, &1) > 0))
    |> Enum.map(fn v ->
      [_ | path] = Graph.dijkstra(graph, current, v)
      {v, path, length(path)}
    end)
    |> Enum.filter(fn {_v, _path, cost} -> time_remaining - cost > 0 end)
  end

  #
  # Part 2
  #

  def simulate_pachyderm({graph, vertex_metadata}, time \\ 26) do
    state = %{
      total_time: time,
      time_remaining: time,
      graph: graph,
      vertices: vertex_metadata,
      opened: %{},
      steps: [{{"AA", time, time}, {"AA", time, time}}],
      stops: [{:me, "AA"}, {:ele, "AA"}]
    }

    memo = %{}

    {result, _memo} = do_simulate_pachyderm(state, memo)
    result
  end

  def do_simulate_pachyderm(
        state = %{
          steps: [last_step | _],
          time_remaining: time_remaining
        },
        memo
      ) do
    cond do
      time_remaining == 0 ->
        {state, memo}

      true ->
        case last_step do
          {{me_current, _, ^time_remaining}, el_last_move} ->
            state
            |> find_options(me_current)
            |> handle_options(
              state,
              memo,
              fn next_stop, next_move_at ->
                {{next_stop, time_remaining, next_move_at}, el_last_move}
              end,
              :me
            )

          {my_last_move, {ele_current, _, ^time_remaining}} ->
            state
            |> find_options(ele_current)
            |> handle_options(
              state,
              memo,
              fn next_stop, next_move_at ->
                {my_last_move, {next_stop, time_remaining, next_move_at}}
              end,
              :ele
            )

          _ ->
            do_simulate_pachyderm(%{state | time_remaining: time_remaining - 1}, memo)
        end
    end
  end

  def find_options(
        %{graph: g, vertices: vs, opened: open_vs, time_remaining: time_remaining},
        current_stop
      ) do
    vs
    |> Map.drop([current_stop | Map.keys(open_vs)])
    |> Enum.filter(&(elem(&1, 1) > 0))
    |> Enum.map(fn {v, _flow} ->
      case Graph.dijkstra(g, current_stop, v) do
        [_ | path] ->
          {v, length(path)}

        nil ->
          nil
      end
    end)
    |> Enum.filter(fn
      {_v, cost} -> time_remaining - cost > 0
      _ -> false
    end)
    |> Enum.map(fn {v, cost} ->
      open_valve_at = time_remaining - cost - 1
      {v, open_valve_at}
    end)
  end

  def handle_options(options, state, memo, build_next_step_fn, who) do
    options
    |> Enum.reduce({state, memo}, fn {next_stop, next_move_at}, {best_state, memo_acc} ->
      next_state = %{
        state
        | opened: Map.put(state.opened, next_stop, next_move_at),
          steps: [
            build_next_step_fn.(next_stop, next_move_at) | state.steps
          ],
          stops: [{who, next_stop} | state.stops]
      }

      {result_state, next_memo_acc} =
        case memo_acc[next_state.opened] do
          nil ->
            do_simulate_pachyderm(
              next_state,
              memo_acc
            )

          memo_state ->
            {memo_state, memo_acc}
        end

      next_best_state = Enum.max_by([best_state, result_state], &score/1)

      {next_best_state, Map.put(next_memo_acc, next_best_state.opened, next_best_state)}
    end)
  end

  #
  # Support
  #

  def score({state, _memo}) do
    score(state)
  end

  def score(state) do
    score(state.vertices, state.opened)
  end

  def score(vs, open_vs) do
    open_vs
    |> Enum.reduce(0, fn {v, time_opened}, acc ->
      acc + time_opened * Map.get(vs, v)
    end)
  end
end

ex_contents
|> Solution.parse()
|> Solution.simulate()
|> then(fn sol -> {sol.stops, Solution.score(sol)} end)
|> IO.inspect(label: "example part 1")

# # VERY SLOW
# input_contents
# |> Solution.parse()
# |> Solution.simulate()
# |> then(fn sol -> {sol.stops, Solution.score(sol)} end)
# |> IO.inspect(label: "input part 1") # => 1460

ex_contents
|> Solution.parse()
|> Solution.simulate_pachyderm()
|> then(fn sol -> {sol.stops, Solution.score(sol)} end)
|> IO.inspect(label: "example part 2")

input_contents
|> Solution.parse()
|> Solution.simulate_pachyderm()
|> then(fn sol -> {sol.stops, Solution.score(sol)} end)
|> IO.inspect(label: "input part 2")

# AA, DD, BB, JJ, HH, EE, CC
