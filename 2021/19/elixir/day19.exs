example = "./example.txt"
input = "./input.txt"

file =
  if System.argv() == ["-e"] do
    example
  else
    input
  end

defmodule Image do
  @light_pixel ?#
  @dark_pixel ?.

  def dimension_ranges(image_lookup) do
    keys = Map.keys(image_lookup)
    min_max_y = keys |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    min_max_x = keys |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    {min_max_y, min_max_x}
  end

  def create_filter_lookup(filter) do
    filter
    |> to_charlist()
    |> Enum.with_index()
    |> Map.new(fn {v, k} -> {k, v} end)
  end

  def create_image_lookup(image) do
    image
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> to_charlist()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{y, x}, c} end)
    end)
    |> Map.new()
  end

  @row1 [{-1, -1}, {-1, 0}, {-1, 1}]
  @row2 [{0, -1}, {0, 0}, {0, 1}]
  @row3 [{1, -1}, {1, 0}, {1, 1}]

  @lens [
          @row1,
          @row2,
          @row3
        ]
        |> List.flatten()

  def lens({y, x}, image_map, filter_lookup, default \\ @dark_pixel) do
    @lens
    |> Enum.map(fn {dy, dx} -> {y + dy, x + dx} end)
    |> Enum.map(fn p -> Map.get(image_map, p, default) end)
    |> Enum.map(fn
      @dark_pixel -> 0
      @light_pixel -> 1
    end)
    |> Integer.undigits(2)
    |> then(fn code -> Map.fetch!(filter_lookup, code) end)
  end

  def enhance(image_map, filter_lookup, step) do
    {{min_y, max_y}, {min_x, max_x}} = Image.dimension_ranges(image_map)

    for y <- (min_y - 1)..(max_y + 1),
        x <- (min_x - 1)..(max_x + 1),
        p = {y, x},
        enhanced =
          Image.lens(
            p,
            image_map,
            filter_lookup,
            if(rem(step, 2) == 0, do: @dark_pixel, else: @light_pixel)
          ),
        into: %{},
        do: {p, enhanced}
  end

  def count(image_map) do
    image_map
    |> Map.values()
    |> Enum.count(fn c -> c == @light_pixel end)
  end

  def print(image_map) do
    {{min_y, max_y}, {min_x, max_x}} = Image.dimension_ranges(image_map)

    min_y..max_y
    |> Enum.map(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        pos = {y, x}
        pixel = Map.get(image_map, pos, @dark_pixel)
      end)
      |> to_string()
    end)
    |> Enum.join("\n")
    |> IO.puts()

    image_map
  end
end

[filter, image] =
  File.read!(file)
  |> String.trim()
  |> String.split("\n\n", trim: true)

filter_lookup = Image.create_filter_lookup(filter)

image_map =
  image
  |> Image.create_image_lookup()

image_map
|> Image.enhance(filter_lookup, 0)
|> Image.enhance(filter_lookup, 1)
# |> Image.print()
|> Image.count()
|> IO.inspect(label: "part1")

0..49
|> Enum.reduce(image_map, fn s, im ->
  Image.enhance(im, filter_lookup, s)
end)
|> Image.count()
|> IO.inspect(label: "part2")
