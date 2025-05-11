defmodule BTZipper do
  alias __MODULE__, as: Z

  defstruct tree: nil, breadcrumbs: [], depth: 1

  @doc """
  Get a zipper focused on the root node.
  """
  def from_tree(bt), do: %Z{tree: bt}

  @doc """
  Get the complete tree from a zipper.
  """
  def to_tree(%Z{tree: t, breadcrumbs: []}), do: t

  def to_tree(%Z{tree: t, breadcrumbs: [{:left, {_l, r}} | parents]}),
    do: to_tree(%Z{tree: {t, r}, breadcrumbs: parents})

  def to_tree(%Z{tree: t, breadcrumbs: [{:right, {l, _r}} | parents]}),
    do: to_tree(%Z{tree: {l, t}, breadcrumbs: parents})

  @doc """
  Get the left child of the focus node, if any.
  """
  def go_left(%Z{tree: {l, _r}}) when is_integer(l), do: nil

  def go_left(%Z{tree: {l, _r} = t} = z),
    do: %{z | tree: l, breadcrumbs: [{:left, t} | z.breadcrumbs], depth: z.depth + 1}

  @doc """
  Get the right child of the focus node, if any.
  """
  def go_right(%Z{tree: {_l, r}}) when is_integer(r), do: nil

  def go_right(%Z{tree: {_l, r} = t} = z),
    do: %{z | tree: r, breadcrumbs: [{:right, t} | z.breadcrumbs], depth: z.depth + 1}

  @doc """
  Get the parent of the focus node, if any.
  """
  def up(%Z{breadcrumbs: []}), do: nil

  def up(%Z{tree: t, breadcrumbs: [{:left, {_l, r}} | parents], depth: depth}),
    do: %Z{tree: {t, r}, breadcrumbs: parents, depth: depth - 1}

  def up(%Z{tree: t, breadcrumbs: [{:right, {l, _r}} | parents], depth: depth}),
    do: %Z{tree: {l, t}, breadcrumbs: parents, depth: depth - 1}

  @doc """
  Set the value of the focus node.
  """
  def set_left_value(%Z{tree: {l, r}} = t, v) when is_integer(l),
    do: {:ok, %{t | tree: {v, r}}}

  def set_left_value(%Z{} = z, _v), do: {:err, z}

  @doc """
  Set the value of the focus node.
  """
  def set_right_value(%Z{tree: {l, r}} = t, v) when is_integer(r),
    do: {:ok, %{t | tree: {l, v}}}

  def set_right_value(%Z{} = z, _v), do: {:err, z}

  @doc """
  Replace the left child tree of the focus node.
  """
  def set_left(%Z{tree: {_, r}} = z, l), do: %{z | tree: {l, r}}

  @doc """
  Replace the right child tree of the focus node.
  """
  def set_right(%Z{tree: {l, _}} = z, r), do: %{z | tree: {l, r}}

  #
  #
  #
  #
  #
  #

  def empty_focus_node(%Z{tree: _t, breadcrumbs: [{:left, {_, r}} | rest], depth: d} = z),
    do: %Z{z | tree: {0, r}, breadcrumbs: rest, depth: d - 1}

  def empty_focus_node(%Z{tree: _t, breadcrumbs: [{:right, {l, _}} | rest], depth: d} = z),
    do: %Z{z | tree: {l, 0}, breadcrumbs: rest, depth: d - 1}

  #
  #
  #
  #
  #
  #

  def set_next_inorder(%Z{tree: {_, b}} = z) do
    case next_inorder(z) do
      {which_value, %Z{tree: {l, r}} = next_inorder, path_back} ->
        case which_value do
          :right_value ->
            {:ok, z} = set_right_value(next_inorder, r + b)
            z

          :left_value ->
            {:ok, z} = set_left_value(next_inorder, l + b)
            z
        end
        |> then(fn z ->
          # {z, path_back} |> IO.inspect(label: "107")

          Enum.reduce(path_back, z, fn
            :up, z ->
              # |> tap(fn x -> {a, x} |> IO.inspect(label: "pathing back") end)
              up(z)

            :left, z ->
              # |> tap(fn x -> {a, x} |> IO.inspect(label: "pathing back") end)
              go_left(z)

            :right, z ->
              # |> tap(fn x -> {a, x} |> IO.inspect(label: "pathing back") end)
              go_right(z)
          end)
        end)

      nil ->
        z
    end
  end

  def next_inorder(%Z{tree: {a, b}} = z)
      when is_integer(a) and is_integer(b) do
    case find_next_search_root(z) do
      {:ok, {root_search, path_to_root}} ->
        find_next_inorder(root_search, path_to_root)

      :none ->
        nil
    end
  end

  defp find_next_search_root(zipper, path \\ [])
  defp find_next_search_root(%Z{breadcrumbs: []}, _acc), do: :none

  defp find_next_search_root(%Z{breadcrumbs: [{:right, _} | _]} = zipper, acc) do
    zipper
    |> up()
    |> find_next_search_root([:right | acc])
  end

  defp find_next_search_root(%Z{breadcrumbs: [{:left, _} | _]} = zipper, acc) do
    zipper
    |> up()
    |> then(fn z -> {z, [:left | acc]} end)
    |> then(&{:ok, &1})
  end

  defp find_next_inorder(%Z{tree: {_, r}} = z, path) when is_integer(r) do
    {:right_value, z, path}
  end

  defp find_next_inorder(%Z{tree: {_, n}} = z, path) when is_tuple(n) do
    z
    |> go_right()
    |> do_find_next_inorder([:up | path])
  end

  defp do_find_next_inorder(%Z{tree: {r, _}} = z, path) when is_integer(r) do
    {:left_value, z, path}
  end

  defp do_find_next_inorder(%Z{tree: {n, _}} = z, path) when is_tuple(n) do
    z
    |> go_left()
    |> do_find_next_inorder([:up | path])
  end

  #
  #
  #
  #
  #
  #

  def set_prev_inorder(%Z{tree: {b, _}} = z) do
    case prev_inorder(z) do
      {which_value, %Z{tree: {l, r}} = prev_inorder, path_back} ->
        case which_value do
          :right_value ->
            {:ok, z} = set_right_value(prev_inorder, r + b)
            z

          :left_value ->
            {:ok, z} = set_left_value(prev_inorder, l + b)
            z
        end
        |> then(fn z ->
          Enum.reduce(path_back, z, fn
            :up, z -> up(z)
            :left, z -> go_left(z)
            :right, z -> go_right(z)
          end)
        end)

      nil ->
        z
    end
  end

  def prev_inorder(%Z{tree: {a, b}} = z)
      when is_integer(a) and is_integer(b) do
    case find_prev_search_root(z) do
      {:ok, {root_search, path_to_root}} ->
        find_prev_inorder(root_search, path_to_root)

      :none ->
        nil
    end
  end

  defp find_prev_search_root(zipper, path \\ [])
  defp find_prev_search_root(%Z{breadcrumbs: []}, _acc), do: :none

  defp find_prev_search_root(%Z{breadcrumbs: [{:left, _} | _]} = zipper, acc) do
    zipper
    |> up()
    |> find_prev_search_root([:left | acc])
  end

  defp find_prev_search_root(%Z{breadcrumbs: [{:right, _} | _]} = zipper, acc) do
    zipper
    |> up()
    |> then(fn z -> {z, [:right | acc]} end)
    |> then(&{:ok, &1})
  end

  defp find_prev_inorder(%Z{tree: {l, _}} = z, path) when is_integer(l) do
    {:left_value, z, path}
  end

  defp find_prev_inorder(%Z{tree: {n, _}} = z, path) when is_tuple(n) do
    z
    |> go_left()
    |> do_find_prev_inorder([:up | path])
  end

  defp do_find_prev_inorder(%Z{tree: {_, r}} = z, path) when is_integer(r) do
    {:right_value, z, path}
  end

  defp do_find_prev_inorder(%Z{tree: {_, n}} = z, path) when is_tuple(n) do
    z
    |> go_right()
    |> do_find_prev_inorder([:up | path])
  end

  def split_left(%Z{tree: {l, r}} = z) do
    split = split_value(l)
    %Z{z | tree: {split, r}}
  end

  def split_right(%Z{tree: {l, r}} = z) do
    split = split_value(r)
    %Z{z | tree: {l, split}}
  end

  def split_value(v) when is_integer(v) do
    half = div(v, 2)
    remainder = rem(v, 2)

    case remainder do
      1 -> {half, half + 1}
      _ -> {half, half}
    end
  end
end
