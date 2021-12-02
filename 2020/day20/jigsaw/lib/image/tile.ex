defmodule Image.Tile do
  @enforce_keys [:data, :number, :top, :bottom, :left, :right, :core]
  defstruct [
    :data,
    :number,
    :top,
    :bottom,
    :left,
    :right,
    :core,
    orientation: 0,
    vflip: false,
    hflip: false
  ]

  @type t() :: %__MODULE__{
          data: list(list(String.t())),
          number: integer(),
          orientation: non_neg_integer(),
          vflip: boolean(),
          hflip: boolean(),
          top: String.t(),
          bottom: String.t(),
          left: String.t(),
          right: String.t(),
          core: list(list(String.t()))
        }

  @spec make(integer(), list(list(String.t()))) :: __MODULE__.t()
  def make(number, data, rotation \\ 0, vflip \\ false, hflip \\ false) do
    %__MODULE__{
      number: number,
      data: data,
      top: find_top(data),
      bottom: find_bottom(data),
      left: find_left(data),
      right: find_right(data),
      core: find_core(data),
      orientation: rotation,
      vflip: vflip,
      hflip: hflip
    }
  end

  @spec from_string(String.t()) :: __MODULE__.t()
  def from_string(string) do
    [title | data] = String.split(string, "\n", trim: true)

    make(
      number_from_title(title),
      Enum.map(data, &String.split(&1, "", trim: true))
    )
  end

  #
  #
  #

  @spec generate_tile_variations(__MODULE__.t()) :: list(__MODULE__.t())
  def generate_tile_variations(%__MODULE__{orientation: o, vflip: v, hflip: h} = tile) do
    for manipulation <- Image.Utility.generate_combinations() do
      case manipulation do
        {^o, ^v, ^h} ->
          tile

        {rotation, vflip, hflip} ->
          manipulated_data = Image.Utility.manipulate_image(tile.data, {rotation, vflip, hflip})
          make(tile.number, manipulated_data, rotation, vflip, hflip)
      end
    end
  end

  #
  #
  #

  @spec to_key(__MODULE__.t()) :: {integer(), non_neg_integer(), boolean(), boolean()}
  def to_key(%__MODULE__{} = tile) do
    {tile.number, tile.orientation, tile.vflip, tile.hflip}
  end

  defp number_from_title(title) do
    title |> String.slice(5..-2) |> String.to_integer()
  end

  defp find_top(data) do
    data |> List.first() |> Enum.join()
  end

  defp find_bottom(data) do
    data |> List.last() |> Enum.join()
  end

  defp find_left(data) do
    data |> Enum.map(&List.first/1) |> Enum.join()
  end

  defp find_right(data) do
    data |> Enum.map(&List.last/1) |> Enum.join()
  end

  defp find_core(data) do
    data |> Enum.slice(1..-2) |> Enum.map(&Enum.slice(&1, 1..-2))
  end
end
