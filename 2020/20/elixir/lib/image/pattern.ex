defmodule Image.Pattern do
  defstruct [:length, :width, :pattern, :points, :pattern_map]

  @wave "#"
  @overwritten "O"

  def seamonster_rows() do
    # [
    #   "                  # ",
    #   "#    ##    ##    ###",
    #   " #  #  #  #  #  #   "
    # ]
    [
      "                  O ",
      "\\    __    __    /=>",
      " \\  /  \\  /  \\  /   "
    ]
  end

  def compile_pattern(pattern) when is_list(pattern) do
    %__MODULE__{
      length: length(pattern),
      width: pattern |> hd |> String.length(),
      pattern: pattern,
      points: find_points(pattern),
      pattern_map:
        pattern
        |> Enum.map(&String.split(&1, "", trim: true))
        |> Image.Utility.image_data_to_map()
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
        {c, x}, acc when c != " " -> [{y, x} | acc]
        _, acc -> acc
      end)
    end)
  end

  def search_and_overwrite_pattern(image_rows, %__MODULE__{} = pattern) do
    for manipulation <- Image.Utility.generate_combinations(),
        manipulated_image = Image.Utility.manipulate_image(image_rows, manipulation),
        coords_of_matches = find_coords_of_matches(manipulated_image, pattern),
        length(coords_of_matches) > 0,
        overwritten_image = overwrite_image(manipulated_image, pattern, coords_of_matches),
        roughness = Image.Utility.count_hashes(overwritten_image) do
      {manipulation, manipulated_image, overwritten_image, coords_of_matches, roughness}
    end
  end

  def overwrite_image(image_data, %__MODULE__{} = pattern, coords_of_matches) do
    image_map = Image.Utility.image_data_to_map(image_data)

    coords_of_matches
    |> Enum.reduce(image_map, fn {dy, dx}, map ->
      pattern.points
      |> Enum.reduce(map, fn {y, x}, m ->
        put_in(m[y + dy][x + dx], pattern.pattern_map[y][x])
      end)
    end)
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0), :asc)
    |> Enum.map(fn {_, row} ->
      row
      |> Map.to_list()
      |> Enum.sort_by(&elem(&1, 0), :asc)
      |> Enum.map(&elem(&1, 1))
    end)
  end

  def find_coords_of_matches(image_rows, pattern) do
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

    image_map = Image.Utility.image_data_to_map(image_rows)

    for y <- 0..(image_length - pattern.length),
        x <- 0..(image_width - pattern.width),
        # |> IO.inspect(label: "66"),
        coords = {y, x},
        pattern_present?(image_map, pattern.points, coords) do
      coords
    end
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

          _ ->
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
