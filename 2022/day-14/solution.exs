#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

[input_file] = System.argv()
{:ok, contents} = File.read(input_file)

defmodule Solution do
  @rock "#"
  @grain "o"

  def to_map(contents) do
    contents
    |> String.split(~r{\n}, trim: true)
    |> Enum.flat_map(fn line ->
      line
      |> String.split(~r{ -> }, trim: true)
      |> Enum.map(fn coord ->
        coord
        |> String.split(~r{,}, trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn
        [{x, y1}, {x, y2}] ->
          for y <- y1..y2, do: {{x, y}, @rock}

        [{x1, y}, {x2, y}] ->
          for x <- x1..x2, do: {{x, y}, @rock}
      end)
    end)
    |> Enum.into(%{})
  end

  @opt_defaults %{
    allow_fall: true,
    max_y: -1,
    max_y_adj_fn: nil,
    starting_point: {500, 0}
  }

  def simulate(map, opts \\ %{}) do
    opts = Map.merge(@opt_defaults, opts)

    opts =
      map
      |> Enum.map(fn {{_x, y}, _} -> y end)
      |> Enum.max()
      |> then(fn max_y -> if opts.max_y_adj_fn, do: opts.max_y_adj_fn.(max_y), else: max_y end)
      |> then(&Map.put(opts, :max_y, &1))

    do_simulate(map, 0, opts)
  end

  def do_simulate(map, i, opts) do
    case drop_sand(opts.starting_point, map, opts) do
      {:settled, result} ->
        do_simulate(result, i + 1, opts)

      {:fall, _result} ->
        i

      {:plugged, _result} ->
        i
    end
  end

  def drop_sand(point, map, opts) do
    case do_drop(point, map, opts) do
      :settled ->
        {:settled, Map.put(map, point, @grain)}

      :fall ->
        if opts.allow_fall, do: {:fall, map}, else: raise("AGH")

      :plugged ->
        {:plugged, map}

      next_point = {_x, _y} ->
        drop_sand(next_point, map, opts)
    end
  end

  def do_drop(point = {x, y}, map, opts) do
    cond do
      Map.has_key?(map, point) -> :plugged
      opts.allow_fall and y > opts.max_y -> :fall
      not opts.allow_fall and y + 1 == opts.max_y -> :settled
      not Map.has_key?(map, {x, y + 1}) -> {x, y + 1}
      not Map.has_key?(map, {x - 1, y + 1}) -> {x - 1, y + 1}
      not Map.has_key?(map, {x + 1, y + 1}) -> {x + 1, y + 1}
      true -> :settled
    end
  end
end

Solution.to_map(contents)
|> Solution.simulate()
|> IO.inspect(label: "part 1")

Solution.to_map(contents)
|> Solution.simulate(%{allow_fall: false, max_y_adj_fn: fn max_y -> max_y + 2 end})
|> IO.inspect(label: "part 2")
