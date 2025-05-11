defmodule Image.Utility do
  @rotations [0, 90, 180, 270]
  @vflip [false, true]
  @hflip [false, true]

  def generate_combinations() do
    for rotation <- @rotations, vflip <- @vflip, hflip <- @hflip, do: {rotation, vflip, hflip}
  end

  def manipulate_image(image_rows, {rotation, vflip, hflip}) do
    turns = rotation |> div(90) |> rem(4)

    image_rows
    |> rotate_image_data(turns)
    |> vertical_flip_image_data(vflip)
    |> horizontal_flip_image_data(hflip)
  end

  #
  #
  #

  @spec rotate_image_data(list(list(String.t())), non_neg_integer()) :: list(list(String.t()))
  def rotate_image_data(image_data, turns \\ 0)

  def rotate_image_data(image_data, 0), do: image_data

  def rotate_image_data(image_data, turns) do
    rotated =
      image_data
      |> Enum.map(&Enum.reverse/1)
      |> transpose()

    rotate_image_data(rotated, turns - 1)
  end

  @spec vertical_flip_image_data(list(list(String.t())), boolean()) :: list(list(String.t()))
  def vertical_flip_image_data(image_data, false), do: image_data

  def vertical_flip_image_data(image_data, true) do
    Enum.reverse(image_data)
  end

  @spec horizontal_flip_image_data(list(list(String.t())), boolean()) :: list(list(String.t()))
  def horizontal_flip_image_data(image_data, false), do: image_data

  def horizontal_flip_image_data(image_data, true) do
    Enum.map(image_data, &Enum.reverse/1)
  end

  defp transpose([]), do: []
  defp transpose([[] | _]), do: []

  defp transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

  #
  #
  #

  def image_data_to_map(image_data) do
    image_data
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {row, y}, map ->
      indexed_row =
        row
        |> Stream.with_index()
        |> Enum.reduce(%{}, fn {cell, x}, map -> Map.put(map, x, cell) end)

      Map.put(map, y, indexed_row)
    end)
  end

  #
  #
  #

  def count_hashes(image_data) do
    image_data
    |> List.flatten()
    |> Enum.count(fn c -> c == "#" end)
  end
end
