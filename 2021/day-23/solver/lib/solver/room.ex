defmodule Solver.Room do
  @enforce_keys [:idx, :maximum, :occupants, :type]
  defstruct [:idx, :maximum, :occupants, :type]

  alias Solver.Piece

  @type t :: %__MODULE__{
          idx: pos_integer(),
          maximum: pos_integer(),
          occupants: list(Piece.t()),
          type: Piece.t()
        }

  @spec new(pos_integer(), pos_integer(), list(Piece.t()), Piece.t()) :: t()
  def new(idx, max, initial, type) do
    %__MODULE__{idx: idx, maximum: max, occupants: initial, type: type}
  end

  @spec matches_type?(Piece.t(), t()) :: boolean()
  def matches_type?(t1, %__MODULE__{type: t2}), do: t1 == t2

  @spec empty?(__MODULE__.t()) :: boolean()
  def empty?(%__MODULE__{occupants: occ}), do: length(occ) == 0

  @spec full?(__MODULE__.t()) :: boolean()
  def full?(%__MODULE__{occupants: occ, maximum: max}), do: length(occ) == max

  @spec satisfied?(__MODULE__.t()) :: boolean()
  def satisfied?(%__MODULE__{occupants: occ, type: type, maximum: max}) do
    length(occ) == max and Enum.all?(&(&1 == type))
  end

  @spec holds_non_type?(__MODULE__.t()) :: boolean()
  def holds_non_type?(%__MODULE__{occupants: occ, type: type}) do
    Enum.any?(occ, &(&1 != type))
  end

  @spec add(__MODULE__.t(), Piece.t()) :: :error | {:ok, __MODULE__.t(), pos_integer()}
  def add(%__MODULE__{occupants: occ, type: type} = room, type) do
    cond do
      full?(room) ->
        :error

      holds_non_type?(room) ->
        :error

      true ->
        {:ok, %__MODULE__{room | occupants: [type | occ]}, 4 - length(occ)}
    end
  end

  def add(_, _), do: :error

  @spec remove(__MODULE__.t()) :: :error | {:ok, Piece.t(), __MODULE__.t(), pos_integer()}
  def remove(%__MODULE__{occupants: [o | o_rest] = occ} = room) do
    if empty?(room) do
      :error
    else
      {:ok, o, %__MODULE__{room | occupants: o_rest}, 5 - length(occ)}
    end
  end

  def has_pieces_to_move?(%__MODULE__{type: type, occupants: occ} = room) do
    not empty?(room) and Enum.any?(occ, &(&1 != type))
  end
end
