fname =
  System.argv()
  |> hd()
  |> IO.inspect(label: "file: ")

lines =
  File.read!(fname)
  |> String.split("\n", trim: true)

[left, right] =
  lists =
  lines
  |> Stream.map(fn line ->
    Regex.scan(~r/\b\d+\b/, line)
    |> Enum.map(&(hd(&1) |> String.to_integer()))
  end)
  |> Stream.zip()
  |> Stream.map(&Tuple.to_list(&1))
  |> Enum.into([])
  |> IO.inspect()

sorted =
  lists
  |> Enum.map(&Enum.sort(&1))
  |> IO.inspect()

# part 1
sorted
|> Stream.zip()
|> Stream.map(fn {l, r} -> abs(r - l) end)
|> Enum.sum()
|> IO.inspect(label: "part 1")

# part 2
right_frequencies =
  right
  |> Enum.frequencies()
  |> IO.inspect()

left_set = Enum.into(left, MapSet.new()) |> IO.inspect()

right_frequencies_filtered =
  right_frequencies
  |> Stream.filter(fn {k, _} -> MapSet.member?(left_set, k) end)
  |> Enum.into(%{})
  |> IO.inspect()

left
|> Stream.map(&(&1 * (right_frequencies_filtered[&1] || 0)))
|> Enum.sum()
|> IO.inspect(label: "part 2")
