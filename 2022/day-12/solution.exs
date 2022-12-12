#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

defmodule Trail do
  @directions [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

  def parse_to_grid(input) do
    input
    |> String.split(~r{\n}, trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> to_charlist()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> do_map_to_grid_entry(y, x, c) end)
    end)
    |> Enum.into(%{})
  end

  defp do_map_to_grid_entry(y, x, character) do
    height = character_to_height(character)
    label = character_to_label(character)

    {{y, x}, %{height: height, label: label, alt: character, position: {y, x}}}
  end

  defp character_to_height(character)
  defp character_to_height(?S), do: ?a - ?a
  defp character_to_height(?E), do: ?z - ?a
  defp character_to_height(c) when c in ?a..?z, do: c - ?a

  defp character_to_label(character)
  defp character_to_label(?S), do: ?a
  defp character_to_label(?E), do: ?z
  defp character_to_label(c) when c in ?a..?z, do: c

  def to_edges(grid_map) do
    grid_map
    |> Enum.reduce([], fn {p1 = {y, x}, %{height: h1}}, edges ->
      @directions
      |> Enum.map(fn {dy, dx} -> Map.get(grid_map, {y + dy, x + dx}) end)
      |> Enum.filter(& &1)
      |> Enum.map(fn %{height: h2, position: p2} ->
        cond do
          h1 + 1 == h2 -> {p1, p2, weight: 1}
          h1 >= h2 -> {p1, p2, weight: 1}
          true -> nil
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.concat(edges)
    end)
    |> Enum.reject(fn {a, b, _} ->
      (a_is_a? = Map.get(grid_map, a).label == ?a) #|> IO.inspect(label: "105")
      (b_is_a? = Map.get(grid_map, b).label == ?a) #|> IO.inspect(label: "106")
      a_is_a? and b_is_a? #|> IO.inspect(label: "107")
    end)
  end

  def find_position(grid_map, key, value) do
    {position, _} =
      Enum.find(grid_map, fn {_, entry} ->
        Map.get(entry, key) == value
      end)
    position
  end

  def find_length_of_path(graph, starting_point, ending_point) do
    solution = Graph.dijkstra(graph, starting_point, ending_point)

    if solution do
      Enum.count(solution) - 1
    end
  end
end


[input_file] = System.argv()
{:ok, contents} = File.read(input_file)

grid_map = Trail.parse_to_grid(contents)
edges = Trail.to_edges(grid_map)
starting_point = Trail.find_position(grid_map, :alt, ?S)
ending_point = Trail.find_position(grid_map, :alt, ?E)

graph =
  Graph.new
  |> Graph.add_edges(edges)

# Part 1

graph
|> Trail.find_length_of_path(starting_point, ending_point)
|> IO.inspect(label: "part_1")

# Part 2

grid_map
|> Enum.filter(fn
  {_, %{height: 0}} -> true
  _ -> false
end)
|> Enum.map(&elem(&1, 0))
|> Enum.map(fn s_point -> Trail.find_length_of_path(graph, s_point, ending_point) end)
|> Enum.filter(& &1)
|> Enum.min()
|> IO.inspect(label: "part_2")

# Part 2 - reversed edges
# hypothesis: on some inputs this is faster because dijkstras hits end node faster
# results: no marginal gain on this input -- meaning input dependent without firther optimization

rev_graph =
  edges
  |> Enum.reject(fn {a, b, _} ->
    (a_is_a? = Map.get(grid_map, a).label == ?a) #|> IO.inspect(label: "105")
    (b_is_a? = Map.get(grid_map, b).label == ?a) #|> IO.inspect(label: "106")
    a_is_a? and b_is_a? #|> IO.inspect(label: "107")
  end)
  |> Enum.map(fn {a, b, params} -> {b, a, params} end)
  |> then(fn edges -> Graph.new |> Graph.add_edges(edges) end)

grid_map
|> Enum.filter(fn
  {_, %{height: 0}} -> true
  _ -> false
end)
|> Enum.map(&elem(&1, 0))
|> Enum.map(fn s_point -> Trail.find_length_of_path(rev_graph, ending_point, s_point) end)
|> Enum.filter(& &1)
|> Enum.min()
|> IO.inspect(label: "part_2 rev")