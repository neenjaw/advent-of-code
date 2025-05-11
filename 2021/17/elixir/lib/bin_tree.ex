defmodule BinTree do
  @type t :: {integer() | t(), integer() | t()}

  @digits ~w{1 2 3 4 5 6 7 8 9 0}

  @spec parse(String.t()) :: t()
  def parse(input) do
    case do_parse(input) do
      {t, c} when c in ["", "]"] -> t
      t -> t
    end
  end

  defp do_parse(<<"[", a::binary-size(1), ",", b::binary-size(1), "]", rest::binary>>) do
    [a, b]
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> then(&{&1, rest})
  end

  defp do_parse(<<"[", rest::binary>>) do
    {left, rest} = do_parse(rest)
    rest = chomp(rest, ",")
    {right, rest} = do_parse(rest)
    rest = chomp(rest, "]")
    {{left, right}, rest}
  end

  defp do_parse(<<a::binary-size(1), rest::binary>>) when a in @digits do
    {String.to_integer(a), rest}
  end

  defp chomp(<<c::binary-size(1), rest::binary>>, c) do
    rest
  end

  def to_string(tree) do
    tree
    |> inspect
    |> String.replace("{", "[")
    |> String.replace("}", "]")
    |> String.replace(", ", ",")
  end

  def sum_magnitude({a, b}) do
    a_sum =
      if is_integer(a) do
        a
      else
        sum_magnitude(a)
      end

    b_sum =
      if is_integer(b) do
        b
      else
        sum_magnitude(b)
      end

    3 * a_sum + 2 * b_sum
  end

  def add(a, b), do: {a, b} |> reduce()

  def reduce(tree) do
    tree1 = do_reduce(tree)

    cond do
      tree == tree1 -> tree1
      true -> reduce(tree1)
    end
  end

  def do_reduce(tree) do
    tree
    |> BTZipper.from_tree()
    |> find_reduction(&check_current_for_explodes/1)
    |> then(fn
      {:explode, zipper} ->
        explode(zipper)

      {:noop, zipper} ->
        zipper
        |> find_reduction(&check_current_for_splits/1)
        |> then(fn
          {:split_left, zipper} ->
            split_left(zipper)

          {:split_right, zipper} ->
            split_right(zipper)

          {:noop, zipper} ->
            zipper
        end)
    end)
    |> BTZipper.to_tree()
  end

  def find_reduction(zipper, check_fn) do
    case do_find_reduction(zipper, check_fn) do
      nil -> {:noop, zipper}
      op -> op
    end
  end

  def do_find_reduction(nil, _), do: nil

  def do_find_reduction(zipper, check_fn) do
    l_find_result =
      zipper
      |> BTZipper.go_left()
      |> do_find_reduction(check_fn)

    case l_find_result do
      nil ->
        case check_fn.(zipper) do
          nil ->
            zipper
            |> BTZipper.go_right()
            |> do_find_reduction(check_fn)

          current_result ->
            current_result
        end

      _ ->
        l_find_result
    end
  end

  def check_current_for_explodes(%BTZipper{depth: depth} = zipper) do
    cond do
      depth > 4 -> {:explode, zipper}
      true -> nil
    end
    |> tap(fn x -> {x, zipper} end)
  end

  def check_current_for_splits(%BTZipper{tree: {l, r}} = zipper) do
    cond do
      is_integer(l) and l > 9 -> {:split_left, zipper}
      is_integer(r) and r > 9 -> {:split_right, zipper}
      true -> nil
    end
    |> tap(fn x -> {x, zipper} end)
  end

  def explode(zipper) do
    zipper
    |> BTZipper.set_next_inorder()
    |> BTZipper.set_prev_inorder()
    |> BTZipper.empty_focus_node()
  end

  def split_left(zipper) do
    BTZipper.split_left(zipper)
  end

  def split_right(zipper) do
    BTZipper.split_right(zipper)
  end
end
