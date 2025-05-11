defmodule Solver.Hallway do
  @enforce_keys [:positions]
  defstruct [:positions]

  alias Solver.Piece

  @type t :: %__MODULE__{
          positions: %{required(pos_integer()) => Piece.t() | :empty}
        }

  @spec new() :: __MODULE__.t()
  def new() do
    %__MODULE__{
      positions: %{
        1 => :empty,
        2 => :empty,
        4 => :empty,
        6 => :empty,
        8 => :empty,
        10 => :empty,
        11 => :empty
      }
    }
  end

  def get_occupied_positions(hallway) do
    Enum.filter(hallway.positions, fn {_, o} -> o !== :empty end)
  end

  def get_choices_from_room(hallway, room_number) do
    {prev, next} =
      hallway.positions
      |> Enum.sort_by(fn {i, _} -> i end, :asc)
      |> Enum.split_while(fn {idx, _hallway} -> idx < room_number end)

    prev =
      prev
      |> Enum.reverse()
      |> Enum.take_while(fn {_, occ} -> occ == :empty end)

    next =
      next
      |> Enum.take_while(fn {_, occ} -> occ == :empty end)

    prev
    |> Kernel.++(next)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort_by(&abs(room_number - &1), :asc)
  end

  def move_to(hallway, piece, room_idx, hallway_idx) do
    case Map.fetch!(hallway.positions, hallway_idx) do
      :empty ->
        {
          abs(room_idx - hallway_idx),
          %{
            hallway
            | positions: %{
                hallway.positions
                | hallway_idx => piece
              }
          }
        }

      _ ->
        raise "shouldnt happen"
    end
  end

  def get_room_choice(hallway, hallway_idx, piece) do
    {prev_hallway, [_ | next_hallway]} =
      hallway.positions
      |> Enum.sort_by(fn {i, _} -> i end, :asc)
      |> Enum.split_while(fn {idx, _hallway} -> idx < hallway_idx end)

    room_idx =
      case piece do
        :A -> 3
        :B -> 5
        :C -> 7
        :D -> 9
      end

    {hallway_path, dir} =
      cond do
        hallway_idx > room_idx -> {prev_hallway |> Enum.reverse(), :desc}
        true -> {next_hallway, :asc}
      end

    [{path_idx, _} | _] =
      hallway_path
      |> Enum.drop_while(fn {i, o} ->
        if dir == :asc do
          i < room_idx and o == :empty
        else
          i > room_idx and o == :empty
        end
      end)

    cond do
      dir == :asc and path_idx < room_idx ->
        nil

      dir == :desc and path_idx > room_idx ->
        nil

      true ->
        {
          room_idx,
          abs(hallway_idx - room_idx),
          %{
            hallway
            | positions: %{
                hallway.positions
                | hallway_idx => :empty
              }
          }
        }
    end
  end
end
