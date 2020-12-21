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
end
