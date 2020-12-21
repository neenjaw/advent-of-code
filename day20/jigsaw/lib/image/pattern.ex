defmodule Image.Pattern do
  defstruct [:length, :width, :pattern]

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
      pattern: pattern
    }
  end

  def search_image_for_pattern(image_rows, %__MODULE__{} = pattern) do
    image_length = image_rows |> length()
    image_width = image_rows |> hd |> String.length()

    if pattern.length > image_length do
      raise ArgumentError,
            "unable to search an image when the pattern's length is longer than the image's length"
    end

    if pattern.width > image_width do
      raise ArgumentError,
            "unable to search an image when the pattern's width is longer than the image's width"
    end

    # prefix_size = 0
    # match?(<<_::binary-size(prefix_size), pattern, _::binary>>, row)

    image_rows
    |> Stream.chunk_every(pattern.length, 1)
    |> Stream.map(fn rows ->
      [pattern.pattern, rows]
      |> Enum.zip()
      |> Enum.reduce(:start, &find_matching_positions(&1, image_width, pattern.width, &2))
    end)
  end

  def find_matching_positions(pattern_image_row_pair, image_width, pattern_width, :start) do
    starting_matching_positions = MapSet.new(0..(image_width - pattern_width))

    find_matching_positions(
      pattern_image_row_pair,
      image_width,
      pattern_width,
      starting_matching_positions
    )
  end

  def find_matching_positions(
        {pattern_row, image_row},
        image_width,
        pattern_width,
        matching_positions
      ) do
  end
end
