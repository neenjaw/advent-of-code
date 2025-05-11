defmodule Image.Scaffold do
  @enforce_keys [:dimension, :grid]
  defstruct [:dimension, :grid]

  def make(dimension) do
    %__MODULE__{
      dimension: dimension,
      grid: 0..(dimension - 1) |> Enum.map(fn i -> {i, make_row(dimension)} end) |> Enum.into(%{})
    }
  end

  defp make_row(dimension) do
    0..(dimension - 1) |> Enum.map(fn i -> {i, nil} end) |> Enum.into(%{})
  end

  def complete?(%__MODULE__{} = scaffold) do
    not Enum.any?(scaffold.grid, fn {_, row} ->
      Enum.any?(row, fn
        {_, nil} -> true
        _ -> false
      end)
    end)
  end

  def scaffold_to_image_rows(%__MODULE__{} = scaffold) do
    cond do
      not complete?(scaffold) ->
        raise ArgumentError, "unable to populate unfinished scaffold"

      true ->
        scaffold.grid
        |> Map.values()
        |> Enum.map(&Map.values/1)
        |> Enum.flat_map(fn row ->
          row
          |> Enum.map(fn key ->
            {:ok, tile} = Image.Tile.Store.get(key)
            tile.core
          end)
          |> Enum.zip()
          |> Enum.map(&(&1 |> Tuple.to_list() |> Enum.concat()))
        end)
    end
  end
end
