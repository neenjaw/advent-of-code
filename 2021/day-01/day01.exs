example = "./example.txt"
input = "./input.txt"

file =
  if System.argv() == ["-e"] do
    example
  else
    input
  end

numbers =
  File.read!(file)
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

chunked_numbers =
  numbers
  |> Enum.chunk_every(3, 1)
  |> Enum.map(&Enum.sum/1)

count_increasing = fn depths ->
  depths
  |> Enum.zip(depths |> tl())
  |> Enum.count(fn {a, b} -> b > a end)
end

numbers
|> count_increasing.()
|> IO.inspect(label: "Part 1")

chunked_numbers
|> count_increasing.()
|> IO.inspect(label: "Part 2")
