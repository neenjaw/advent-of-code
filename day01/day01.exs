defmodule Day01 do
  defmodule Lookup do
    use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    end

    def init(_) do
      :ets.new(
        __MODULE__,
        [:named_table, :public, write_concurrency: true]
      )

      {:ok, nil}
    end

    def put(value) do
      :ets.insert(__MODULE__, {value, true})
    end

    def has_value?(value) do
      case :ets.lookup(__MODULE__, value) do
        [{^value, _}] -> true
        _ -> false
      end
    end
  end

  def part1(args, goal \\ 2020) do
    Lookup.start_link()

    x =
      args
      |> Enum.find(fn n ->
        case Lookup.has_value?(goal - n) do
          false ->
            Lookup.put(n)
            false

          true ->
            true
        end
      end)

    case x do
      nil ->
        nil

      _ ->
        (goal - x) * x
    end
  end

  def part2(values, goal \\ 2020)

  def part2([], _goal) do
    nil
  end

  def part2([value | remaining], goal) do
    case part1(remaining, goal - value) do
      nil -> part2(remaining, goal)
      x -> x * value
    end
  end
end

input =
  "./input.txt"
  |> File.stream!([], :line)
  |> Stream.map(fn x ->
    x |> String.trim() |> String.to_integer()
  end)
  |> Enum.to_list()

input
|> Day01.part1()
|> IO.inspect(label: "Part 1 Results")

input
|> Day01.part2()
|> IO.inspect(label: "Part 2 Results")
