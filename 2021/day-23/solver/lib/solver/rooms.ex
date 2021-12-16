defmodule Solver.Rooms do
  @enforce_keys [:rooms]
  defstruct [:rooms]

  alias Solver.Room

  @type t :: %__MODULE__{
          rooms: %{
            required(pos_integer()) => Room.t()
          }
        }

  def initial() do
    %__MODULE__{
      rooms: %{
        3 => Room.new(3, 4, [:C, :D, :D, :B], :A),
        5 => Room.new(5, 4, [:D, :C, :B, :A], :B),
        7 => Room.new(7, 4, [:D, :B, :A, :B], :C),
        9 => Room.new(9, 4, [:A, :A, :C, :C], :D)
      }
    }
  end

  def complete() do
    %__MODULE__{
      rooms: %{
        3 => Room.new(3, 4, [:A, :A, :A, :A], :A),
        5 => Room.new(5, 4, [:B, :B, :B, :B], :B),
        7 => Room.new(7, 4, [:C, :C, :C, :C], :C),
        9 => Room.new(9, 4, [:D, :D, :D, :D], :D)
      }
    }
  end

  def complete?(rooms), do: complete() == rooms

  def has_pieces_to_move?(rooms, number) do
    Room.has_pieces_to_move?(rooms.rooms[number])
  end

  def fetch!(rooms, n) do
    Map.fetch!(rooms.rooms, n)
  end

  def remove_from_room(rooms, room_idx) do
    {:ok, piece, next_room, move_out_cost} =
      rooms
      |> fetch!(room_idx)
      |> Room.remove()

    {:ok, piece, %{rooms | rooms: %{rooms.rooms | room_idx => next_room}}, move_out_cost}
  end
end
