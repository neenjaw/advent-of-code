defmodule Image do
  defguard is_out_of_bounds(index, dimension) when index < 0 or index >= dimension

  def from_file(file) do
    input_tiles =
      file
      |> String.trim()
      |> String.split("\n\n", trim: true)
      |> Enum.map(&Image.Tile.from_string/1)

    image_dimension = input_tiles |> length() |> :math.sqrt() |> trunc
    tile_variations = Enum.flat_map(input_tiles, &Image.Tile.generate_tile_variations/1)

    Enum.each(tile_variations, fn tile -> Image.Tile.Store.put(tile) end)

    adjacency_table = find_potentials(tile_variations)

    image_scaffold =
      adjacency_table
      |> find_starting_points()
      |> Enum.find_value(:no_solution, &search(adjacency_table, image_dimension, &1))
  end

  def find_potentials(tiles) do
    Enum.reduce(tiles, %{}, fn tile, memo ->
      sides_to_check = [
        {:left, :right},
        {:top, :bottom},
        {:right, :left},
        {:bottom, :top}
      ]

      possibilities =
        for other_tile <- tiles,
            other_tile.number != tile.number,
            {side, complement_side} <- sides_to_check,
            Map.get(tile, side) == Map.get(other_tile, complement_side) do
          {side, Image.Tile.to_key(other_tile)}
        end

      grouped_by_side = Enum.group_by(possibilities, &elem(&1, 0))
      Map.put(memo, Image.Tile.to_key(tile), grouped_by_side)
    end)
  end

  def find_starting_points(potential_adjacent) do
    potential_adjacent
    |> Enum.filter(fn
      {{_, 0, false, false}, adjacent} ->
        case Map.keys(adjacent) do
          keys when length(keys) == 2 -> true
          _ -> false
        end

      _ ->
        false
    end)
  end

  def search(table, dimension, coord \\ nil, point, image \\ nil)

  def search(table, dimension, coord, point, nil) do
    search(table, dimension, coord, point, Image.Scaffold.make(dimension))
  end

  def search(table, dimension, nil, {_, adjacency} = point, image) do
    coord = find_starting_coordinates(dimension, adjacency)
    search(table, dimension, coord, point, image)
  end

  def search(table, dimension, {y, x} = coords, {tile, _} = point, image) do
    # |> IO.inspect(label: "search")
    image = put_in(image.grid[y][x], tile)

    cond do
      Image.Scaffold.complete?(image) ->
        # IO.puts("Complete")
        image

      true ->
        # IO.puts("Not Complete: searching")
        do_search(table, dimension, coords, point, image)
    end
  end

  def do_search(table, dimension, coords, {_tile, adjacency}, image) do
    # tile |> IO.inspect(label: "tile")

    adjacency
    |> Enum.flat_map(fn {_, list} -> list end)
    # |> IO.inspect(label: "adjacent_to")
    |> Enum.find_value(fn {direction, adjacent_tile} ->
      case find_next_coordinates(image, dimension, direction, coords) do
        {_, _} = next_coords ->
          # case next_coords do
          #   {_, x} when x in 1..2 ->
          #     IO.puts(IO.ANSI.red() <> "HERE" <> IO.ANSI.reset())

          #   _ ->
          #     nil
          # end

          cond do
            # , debug: elem(coords, 1) in 1..2) ->
            match_adjacent(image, next_coords, adjacent_tile) ->
              search(table, dimension, next_coords, {adjacent_tile, table[adjacent_tile]}, image)

            true ->
              # One or more sides did not match
              false
          end

        :out_of_bounds ->
          false

        :already_occupied ->
          false
      end
    end)
  end

  def match_adjacent(image, {y, x}, {_, _, _, _} = tile, opts \\ []) do
    debug = Keyword.get(opts, :debug, false)

    {:ok, tile} = Image.Tile.Store.get(tile)

    if debug do
      # |> IO.inspect(label: "tile")
      tile
    end

    # {relative coordinate, {side of the tile to check, side of the adjacent to check}}
    adjacent_coords = [
      {{1, 0}, {:bottom, :top}},
      {{-1, 0}, {:top, :bottom}},
      {{0, 1}, {:right, :left}},
      {{0, -1}, {:left, :right}}
    ]

    adjacent_coords
    |> Enum.all?(fn {{dy, dx}, {tile_side, complement_side}} ->
      # IO.inspect(binding(), label: " to compare")

      case image.grid[y + dy][x + dx] do
        nil ->
          true

        {_, _, _, _} = adjacent_key ->
          {:ok, adjacent_tile} = Image.Tile.Store.get(adjacent_key)
          Map.get(tile, tile_side) == Map.get(adjacent_tile, complement_side)
      end

      # |> IO.inspect(label: "compare_result")
    end)
  end

  #
  #
  #

  def find_starting_coordinates(dimension, %{top: _, left: _}) do
    {dimension - 1, dimension - 1}
  end

  def find_starting_coordinates(dimension, %{top: _, right: _}) do
    {dimension - 1, 0}
  end

  def find_starting_coordinates(dimension, %{bottom: _, left: _}) do
    {0, dimension - 1}
  end

  def find_starting_coordinates(_dimension, %{bottom: _, right: _}) do
    {0, 0}
  end

  #
  #
  #

  def find_next_coordinates(image, dimension, :right, {y, x}) do
    check_next_coordinates(image, dimension, {y, x + 1})
  end

  def find_next_coordinates(image, dimension, :left, {y, x}) do
    check_next_coordinates(image, dimension, {y, x - 1})
  end

  def find_next_coordinates(image, dimension, :top, {y, x}) do
    check_next_coordinates(image, dimension, {y - 1, x})
  end

  def find_next_coordinates(image, dimension, :bottom, {y, x}) do
    check_next_coordinates(image, dimension, {y + 1, x})
  end

  defp check_next_coordinates(_image, dimension, {y, x})
       when is_out_of_bounds(y, dimension) or is_out_of_bounds(x, dimension),
       do: :out_of_bounds

  defp check_next_coordinates(image, _dimension, {y, x} = coords) do
    case image.grid[y][x] do
      nil -> coords
      _ -> :already_occupied
    end
  end
end
