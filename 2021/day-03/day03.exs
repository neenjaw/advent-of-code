# defmodule AoC do
#   def findCommon(report) do
#     report
#     |> Enum.map(&to_charlist/1)
#     |> Enum.zip()
#     |> Enum.map(&findMostCommonInRow/1)
#   end

#   defp findMostCommonInRow(row) do
#     %{?1 => ones, ?0 => zeros} =
#       row
#       |> Tuple.to_list()
#       |> Enum.frequencies()

#     cond do
#       ones > zeros -> :ones
#       zeros > ones -> :zeros
#       true -> :equal
#     end
#   end
# end

# example = "./example.txt"
# input = "./input.txt"

# file =
#   if System.argv() == ["-e"] do
#     example
#   else
#     input
#   end

# numbers =
#   File.read!(file)
#   |> String.trim()
#   |> String.split("\n", trim: true)
#   |> AoC.findCommon()
#   |> IO.inspect(label: "20")
