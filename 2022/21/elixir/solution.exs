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
    input
    |> parse()
    |> solve()
  end

  @doc """
  Parse creates a graph from the input equations, where the formats:

    aaaa: bbbb + cccc

  or

    dddd: 5

  become vertices named by the left hand portion of the `:` and the content of the equation as
  part of the label.  This is used later to evaluate them in order using topological sort to
  find the answer of the value.
  """
  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(Graph.new(), fn line, graph ->
      ~r/((\w+): (\d+))|((\w+): (\w+) (\+|\-|\*|\/) (\w+))/
      |> Regex.run(line, capture: :all_but_first)
      |> case do
        [_, _, _, _, label, left, op, right] ->
          graph
          |> Graph.add_edge(left, label)
          |> Graph.add_edge(right, label)
          |> Graph.label_vertex(label, {left, String.to_existing_atom(op), right})

        [_, label, n] ->
          graph
          |> Graph.add_vertex(label)
          |> Graph.label_vertex(label, {label, String.to_integer(n)})
      end
    end)
  end

  def solve(graph) do
    order = Graph.topsort(graph)
    root = List.last(order)
    Enum.reduce(order, %{}, &do_solve(graph, &1, &2))[root]
  end

  def do_solve(graph, label, prev) do
    res =
      case Graph.vertex_labels(graph, label) do
        [{l, op, r}] -> exec(op, prev[l], prev[r])
        [{_, n}] -> n
      end

    Map.put(prev, label, res)
  end

  def exec(:+, l, r), do: l + r
  def exec(:-, l, r), do: l - r
  def exec(:*, l, r), do: l * r
  def exec(:/, l, r), do: div(l, r)

  def part2(input) do
    graph = parse(input)
    {humn, other} = split(graph, "root")
    answer = solve(other)

    path = graph |> Graph.get_shortest_path("humn", "root") |> Enum.reverse()

    humn
    |> Graph.add_vertex("root", {"root", answer})
    |> Graph.delete_vertex("humn")
    |> reverse_path(path)
    |> solve()
  end

  @doc """
  Split the super-graph at the node "root" such that you have two graphs. One that
  contains "humn" one that doesn't  Not sure if the resulting subgraph is provably
  disjoint, but that doesn't seem to matter.
  """
  def split(graph, root) do
    graph
    |> Graph.delete_vertex(root)
    |> Graph.components()
    |> Enum.split_with(&("humn" in &1))
    |> Tuple.to_list()
    |> Enum.map(fn [vs] -> Graph.subgraph(graph, vs) end)
    |> List.to_tuple()
  end

  @doc """
  Reverse the graph such that the edges are repointed backwards
  Also the equations need to be reconfigured so that the new node is the result
  of the equation.
  """
  def reverse_path(graph, path) do
    path
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.reduce(graph, fn [from, to, next], graph ->
      [op] = Graph.vertex_labels(graph, to)

      graph
      |> Graph.add_edge(from, to)
      |> Graph.delete_edge(to, from)
      |> Graph.remove_vertex_labels(to)
      |> Graph.label_vertex(to, reorder_equation(op, from, next))
    end)
  end

  def reorder_equation({next, :+, other}, from, next), do: {from, :-, other}
  def reorder_equation({other, :+, next}, from, next), do: {from, :-, other}
  def reorder_equation({next, :-, other}, from, next), do: {other, :+, from}
  def reorder_equation({other, :-, next}, from, next), do: {other, :-, from}
  def reorder_equation({next, :*, other}, from, next), do: {from, :/, other}
  def reorder_equation({other, :*, next}, from, next), do: {from, :/, other}
  def reorder_equation({next, :/, other}, from, next), do: {from, :*, other}
  def reorder_equation({other, :/, next}, from, next), do: {other, :/, from}
end

Solution.read_example()
|> Solution.part1()
|> then(fn result -> if result != 152, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "example part 1")

Solution.read_input()
|> Solution.part1()
|> then(fn result ->
  if result != 93_813_115_694_560, do: raise("#{result}"), else: result
end)
|> IO.inspect(label: "input part 1")

Solution.read_example()
|> Solution.part2()
|> then(fn result -> if result != 301, do: IO.puts("#{result}"), else: result end)
|> IO.inspect(label: "example part 2")

Solution.read_input()
|> Solution.part2()
|> then(fn result -> if result != 3_910_938_071_092, do: raise("#{result}"), else: result end)
|> IO.inspect(label: "input part 2")
