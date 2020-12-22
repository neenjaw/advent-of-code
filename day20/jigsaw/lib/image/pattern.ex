defmodule Image.Pattern do
  defstruct [:length, :width, :pattern, :points]

  @wave "#"
  @overwritten "O"

  def seamonster_rows() do
    [
      "                  # ",
      "#    ##    ##    ###",
      " #  #  #  #  #  #   "
    ]
  end

  def compile_pattern(pattern) when is_list(pattern) do
    %__MODULE__{
      length: length(pattern),
      width: pattern |> hd |> String.length(),
      pattern: pattern,
      points: find_points(pattern)
    }
  end

  def find_points(pattern) do
    pattern
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x}, acc -> [{y, x} | acc]
        _, acc -> acc
      end)
    end)
  end

  def search_and_overwrite_pattern(image_rows, %__MODULE__{} = pattern) do
    image_length = image_rows |> length()
    image_width = image_rows |> hd |> length()

    if pattern.length > image_length do
      raise ArgumentError,
            "unable to search an image when the pattern's length is longer than the image's length"
    end

    if pattern.width > image_width do
      raise ArgumentError,
            "unable to search an image when the pattern's width is longer than the image's width"
    end

    image_map =
      image_rows
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {row, y}, map ->
        indexed_row =
          row
          |> Stream.with_index()
          |> Enum.reduce(%{}, fn {cell, x}, map -> Map.put(map, x, cell) end)

        Map.put(map, y, indexed_row)
      end)

    for y <- 0..(image_length - pattern.length),
        x <- 0..(image_width - pattern.width),
        # |> IO.inspect(label: "66"),
        coords = {y, x},
        pattern_present?(image_map, pattern.points, coords) do
      coords
    end

    # Then overwrite the map from coords
  end

  def pattern_present?(image_map, points, {y, x}) do
    found? =
      points
      # |> IO.inspect(label: "75")
      |> Enum.all?(fn {dy, dx} ->
        case image_map[y + dy][x + dx] do
          @wave ->
            true

          @overwritten ->
            # IO.puts(
            #   IO.ANSI.red() <>
            #     "WARNING, FOUND OVERLAPPING SEA-MONSTER AT {y: #{y + dy}, x: #{x + dx}}" <>
            #     IO.ANSI.reset()
            # )

            true

          c ->
            # |> IO.inspect(label: "90")
            c
            false
        end
      end)

    if found? do
      IO.puts(
        IO.ANSI.green() <>
          "FOUND SEA-MONSTER AT {y: #{y}, x: #{x}}" <> IO.ANSI.reset()
      )

      true
    else
      false
    end
  end

  # def search_image_for_pattern(image_rows, %__MODULE__{} = pattern) do
  #   image_length = image_rows |> length()
  #   image_width = image_rows |> hd |> String.length()

  #   if pattern.length > image_length do
  #     raise ArgumentError,
  #           "unable to search an image when the pattern's length is longer than the image's length"
  #   end

  #   if pattern.width > image_width do
  #     raise ArgumentError,
  #           "unable to search an image when the pattern's width is longer than the image's width"
  #   end

  #   image_rows
  #   |> Stream.chunk_every(pattern.length, 1)
  #   |> Stream.map(fn rows ->
  #     [pattern.pattern, rows]
  #     |> Enum.zip()
  #     |> Enum.reduce(:start, &find_matching_positions(&1, image_width, pattern.width, &2))
  #     |> MapSet.size()
  #   end)
  #   |> Enum.sum()
  # end

  # def find_matching_positions(pattern_image_row_pair, image_width, pattern_width, :start) do
  #   starting_matching_positions = MapSet.new(0..(image_width - pattern_width))

  #   find_matching_positions(
  #     pattern_image_row_pair,
  #     image_width,
  #     pattern_width,
  #     starting_matching_positions
  #   )
  # end

  # def find_matching_positions(
  #       {pattern_row, image_row},
  #       image_width,
  #       pattern_width,
  #       matching_positions
  #     ) do
  #   0..(image_width - pattern_width)
  #   |> Enum.filter(&match_at?(pattern_row, image_row, &1))
  #   |> MapSet.new()
  #   |> MapSet.intersection(matching_positions)
  # end

  # defp match_at?(pattern_row, image_row, start_at, index \\ 0)

  # defp match_at?(pattern_row, <<_, image_row::binary>>, start_at, index)
  #      when start_at > index do
  #   match_at?(pattern_row, image_row, start_at, index + 1)
  # end

  # defp match_at?(<<"#", pattern_row::binary>>, <<"#", image_row::binary>>, s, i) do
  #   match_at?(pattern_row, image_row, s, i + 1)
  # end

  # defp match_at?(<<" ", pattern_row::binary>>, <<_, image_row::binary>>, s, i) do
  #   match_at?(pattern_row, image_row, s, i + 1)
  # end

  # defp match_at?(<<>>, _, _, _) do
  #   true
  # end

  # defp match_at?(_, _, _, _) do
  #   false
  # end
end
