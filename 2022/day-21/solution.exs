#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}, {:muscat, "~> 0.3"}])

defmodule Solution do
  def read_example() do
    {:ok, ex_contents} = File.read("./2022/day-21/example.txt")
    ex_contents
  end

  def read_input() do
    {:ok, input_contents} = File.read("./2022/day-21/input.txt")
    input_contents
  end

  def part1(input) do
    rules =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&to_rule/1)

    lookup = Enum.into(rules, %{}, &{&1.tag, &1})

    edges = Enum.flat_map(rules, fn rule -> Enum.map(rule.inputs, &{&1, rule.tag}) end)

    g = Graph.new() |> Graph.add_edges(edges)

    topsorted =
      case Graph.topsort(g) do
        order = [:root | _] ->
          Enum.reverse(order)

        order when is_list(order) ->
          order

        false ->
          edges_rev = Enum.map(edges, fn {a, b} -> {b, a} end)
          g_rev = Graph.new() |> Graph.add_edges(edges_rev)
          x = Graph.reachable_neighbors(g_rev, [:root])
          {length(x), x, Enum.member?(x, :root)} |> IO.inspect(label: "38")
          raise "1"
      end

    solve_ordered(%{}, topsorted, lookup, "root")
  end

  def to_rule(line) do
    [tag | inputs] =
      Regex.scan(~r/\b([a-zA-Z]+)\b/, line)
      |> Enum.map(&hd/1)

    op =
      case Regex.scan(~r/([+\/*-])/, line) do
        [] -> nil
        [[op | _]] -> op
      end

    equation = String.replace(line, ":", "=")

    ## TODO: combine all of the

    evaluation_fn = fn values, current_monkey ->
      input_binding = Enum.map(inputs, fn input -> {String.to_atom(input), values[input]} end)

      case Enum.filter(input_binding, &(elem(&1, 1) == nil)) do
        [] ->
          {_, binding} = Code.eval_string(equation, input_binding)

          {:ok,
           Map.merge(
             values,
             Enum.into(binding, %{}, fn {key, v} -> {Atom.to_string(key), trunc(v)} end)
           )}

        l ->
          {:value_missing, length(l), tag, l, equation, values}
      end
    end

    rev_evaluation_fn = fn values, current_monkey ->
      case op do
        nil ->
          {:ok,
           Map.merge(
             values,
             Enum.into(binding, %{}, fn {key, v} -> {Atom.to_string(key), trunc(v)} end)
           )}

        _ ->
          [l_value, r_value] = inputs

          rev_equation =
            case {current_monkey, tag, l_value, op, r_value} do
              {c, t, c, "+", r} ->
                {c, t, "-", r}

              {c, t, l, "+", c} ->
                {c, t, "-", l}

              {c, t, c, "-", r} ->
                {c, t, "+", r}

              {c, t, l, "-", c} ->
                {c, l, "-", t}

              {c, t, c, "*", r} ->
                {c, t, "/", r}

              {c, t, l, "*", c} ->
                {c, t, "/", l}

              {c, t, c, "/", r} ->
                {c, t, "*", r}

              {c, t, l, "/", c} ->
                {c, l, "*", t}
            end
            |> then(fn {out, l, op, r} -> "#{out} = #{l} #{op} #{r}" end)

          input_binding =
            Enum.map([tag | inputs] -- [current_monkey], fn input ->
              {String.to_atom(input), values[input]}
            end)

          {_, binding} = Code.eval_string(rev_equation, input_binding)

          {:ok,
           Map.merge(
             values,
             Enum.into(binding, %{}, fn {key, v} -> {Atom.to_string(key), trunc(v)} end)
           )}
      end
    end

    %{
      tag: tag,
      inputs: inputs,
      eval: evaluation_fn,
      equation: equation,
      op: op
    }
  end

  def solve_ordered(values, [], _, _, _), do: {:error, values}

  def solve_ordered(values = %{}, [next | rest], rulemap = %{}, goal) do
    {:ok, next_values} = Map.get(rulemap, next).eval.(values, next)
    check_solve_ordered(next_values, rest, rulemap, goal, eval_fn_name)
  end

  def check_solve_ordered(values, topo, lookup, goal) do
    if Map.has_key?(values, goal) do
      {:ok, Map.get(values, goal), values}
    else
      solve_ordered(values, topo, lookup, goal)
    end
  end

  @root "root"
  @me "humn"

  def part2(input) do
    lookup =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&to_rule/1)
      |> Enum.into(%{}, &{&1.tag, &1})

    root_rule = Map.get(lookup, @root)
    [a_root, b_root] = root_rule.inputs |> IO.inspect(label: "105")

    lookup = Map.delete(lookup, @root)
    lookup = Map.delete(lookup, @me)

    edges = Enum.flat_map(lookup, fn {_, rule} -> Enum.map(rule.inputs, &{&1, rule.tag}) end)
    edges_rev = Enum.map(edges, fn {a, b} -> {b, a} end)

    g = Graph.new() |> Graph.add_edges(edges)
    g_rev = Graph.new() |> Graph.add_edges(edges_rev)

    Graph.reachable(g, [@me]) |> IO.inspect(label: "118")
    Graph.reachable(g_rev, [@me]) |> IO.inspect(label: "119")

    forward_topsort = Graph.topsort(g) |> IO.inspect(label: "116") |> tl()
    root_input_a = List.last(forward_topsort)
    root_input_b = if root_input_a == a_root, do: b_root, else: a_root
    backward_topsort = Graph.topsort(g_rev) |> IO.inspect(label: "119")

    a_reachable =
      [a_root | Graph.reachable_neighbors(g_rev, [a_root])]
      |> MapSet.new()
      |> IO.inspect(label: "106")

    b_reachable =
      [b_root | Graph.reachable_neighbors(g_rev, [b_root])]
      |> MapSet.new()
      |> IO.inspect(label: "107")

    {first_goal, complement, forward_nodes, backward_nodes} =
      cond do
        MapSet.member?(a_reachable, @me) -> {b_root, a_root, b_reachable, a_reachable}
        MapSet.member?(b_reachable, @me) -> {a_root, b_root, a_reachable, b_reachable}
        true -> raise "whaaaaa"
      end
      |> IO.inspect(label: "142")

    forward_pared_edges =
      Enum.filter(edges, fn {a, b} ->
        MapSet.member?(forward_nodes, a) or MapSet.member?(forward_nodes, b)
      end)
      |> IO.inspect(label: "148")

    g_complete = Graph.new() |> Graph.add_edges(forward_pared_edges)

    backward_pared_edges =
      Enum.filter(edges_rev, fn {a, b} ->
        MapSet.member?(backward_nodes, a) or MapSet.member?(backward_nodes, b)
      end)

    g_complete = g_complete |> Graph.add_edges([{first_goal, complement} | backward_pared_edges])

    topsorted =
      case Graph.topsort(g_forward) do
        false ->
          raise "could not topsort"

        order ->
          order
      end
      |> IO.inspect(label: "170")

    solve_ordered(%{}, forward_topsorted, lookup, first_goal)
  end
end

Solution.read_example()
|> Solution.part1()
|> then(fn {:ok, result, _} -> if result != 152, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> then(fn {:ok, result, _} ->
  if result != 93_813_115_694_560, do: raise("#{result}"), else: result
end)
|> IO.inspect(label: "input part 1")

Solution.read_example()
|> Solution.part2()
|> then(fn {:ok, result} -> if result != 3348, do: IO.puts("#{result}"), else: result end)
|> IO.inspect(label: "example part 2")

Solution.read_input()
|> Solution.part2()
# |> then(fn {:ok, result} -> if result != 3510, do: raise("#{result}"), else: result end)
|> IO.puts()
