#! /usr/bin/env elixir

Mix.install([:jason, {:libgraph, "~> 0.16.0"}])

[input_file] = System.argv()
{:ok, contents} = File.read(input_file)

defmodule Solution do
  def inorder([], [_ | _]), do: true
  def inorder([_ | _], []), do: false
  def inorder(eq, eq), do: :indeterminate
  def inorder([eq | lt], [eq | rt]), do: inorder(lt, rt)
  def inorder([l | _lt], [r | _rt]) when is_integer(l) and is_integer(r), do: l < r
  def inorder([l | lt], [r | rt]) when is_integer(l) and is_list(r), do: inorder([[l] | lt], [r | rt])
  def inorder([l | lt], [r | rt]) when is_list(l) and is_integer(r), do: inorder([l | lt], [[r] | rt])
  def inorder([l | lt], [r | rt]) when is_list(l) and is_list(r) do
    case inorder(l, r) do
      :indeterminate -> inorder(lt, rt)
      result -> result
    end
  end
end

contents
|> String.split(~r{\n\n}, trim: true)
|> Enum.map(fn line ->
  line
  |> String.split(~r{\n}, trim: true)
  |> Enum.map(fn side ->
    {result, _} = Code.eval_string(side)
    result
  end)
end)
|> Enum.with_index(1)
|> Enum.reduce(0, fn {[left, right], i}, acc ->
  if Solution.inorder(left, right) do
    acc + i
  else
    acc
  end
end)
|> IO.inspect(label: "part 1")

d1 = [[2]]
d2 = [[6]]

contents
|> String.split(~r{\n}, trim: true)
|> Enum.map(fn line ->
  {result, _} = Code.eval_string(line)
  result
end)
|> Enum.concat([d1, d2])
|> Enum.sort(fn a, b -> Solution.inorder(a, b) end)
|> Enum.with_index(1)
|> Enum.reduce(1, fn
  {l, i}, acc when l in [d1, d2] -> acc * i
  _, acc -> acc
end)
|> IO.inspect(label: "part 2")
