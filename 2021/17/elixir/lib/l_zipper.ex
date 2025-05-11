defmodule LZipper do
  alias __MODULE__, as: Z

  defstruct list: nil, breadcrumbs: [], depth: 0

  def from_list(list), do: %Z{list: list}

  def to_list(%Z{list: l, breadcrumbs: []}), do: l

  def to_list(%Z{list: l, breadcrumbs: [node | parents]}),
    do: to_list(%Z{list: [node | l], breadcrumbs: parents})

  def go_left(%Z{list: _l, breadcrumbs: []}), do: nil

  def go_left(%Z{list: l, breadcrumbs: [node | rest]} = z),
    do: %{z | list: [node | l], breadcrumbs: rest}

  def go_right(%Z{list: [_node]}), do: nil

  def go_right(%Z{list: [node | rest]} = z),
    do: %{z | list: rest, breadcrumbs: [node | z.breadcrumbs]}

  def set_value(%Z{list: [_node, rest]} = t, v),
    do: {:ok, do: %{t | list: [v | rest]}}

  # def explode_node(%Z{list: [, rest]} = t, v)
end
