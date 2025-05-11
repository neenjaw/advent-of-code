defmodule Solver do
  require IEx

  alias Solver.{
    Rooms,
    Room,
    Hallway
  }

  def part2() do
    starting_rooms = Rooms.initial()
    starting_hallway = Hallway.new()

    print(starting_hallway, starting_rooms)
    |> IO.puts()

    {:found, path} = run(starting_rooms, starting_hallway)

    cost = path_cost(path)

    {path, cost}
  end

  def path_cost(path, acc \\ 0)
  def path_cost([], acc), do: acc
  def path_cost([{:A, n, _, _} | rest], acc), do: path_cost(rest, acc + n)
  def path_cost([{:B, n, _, _} | rest], acc), do: path_cost(rest, acc + 10 * n)
  def path_cost([{:C, n, _, _} | rest], acc), do: path_cost(rest, acc + 100 * n)
  def path_cost([{:D, n, _, _} | rest], acc), do: path_cost(rest, acc + 1000 * n)

  @spec run(Rooms.t(), Hallway.t(), list({Piece.t(), pos_integer()})) :: any()
  def run(rooms, hallway, path \\ []) do
    Enum.find_value([:move_out, :move_in], fn
      :move_out ->
        [3, 5, 7, 9]
        |> Enum.filter(&Rooms.has_pieces_to_move?(rooms, &1))
        |> Enum.find_value(fn room_choice ->
          Hallway.get_choices_from_room(hallway, room_choice)
          |> then(fn
            [] ->
              nil

            choices ->
              choices
              |> Enum.find_value(fn hallway_choice ->
                {:ok, piece, next_rooms, move_out_cost} =
                  Rooms.remove_from_room(rooms, room_choice)

                {move_to_hallway_cost, next_hallway} =
                  Hallway.move_to(hallway, piece, room_choice, hallway_choice)

                distance_moved = move_out_cost + move_to_hallway_cost

                run(next_rooms, next_hallway, [
                  {piece, distance_moved, :out, {room_choice, hallway_choice}} | path
                ])
              end)
          end)
        end)

      :move_in ->
        hallway
        |> Hallway.get_occupied_positions()
        |> Enum.find_value(fn {choice, piece} ->
          case Hallway.get_room_choice(hallway, choice, piece) do
            {room_idx, cost_to_room, updated_hallway} ->
              case move_to_room(rooms, room_idx, piece) do
                {cost_to_put_in_room, updated_rooms} ->
                  next_path = [
                    {piece, cost_to_put_in_room + cost_to_room, :in, {choice, room_idx}} | path
                  ]

                  if Rooms.complete?(updated_rooms) do
                    {:found, next_path}
                  else
                    run(updated_rooms, updated_hallway, next_path)
                  end

                _ ->
                  nil
              end

            nil ->
              nil
          end
        end)
    end)
  end

  def move_to_room(rooms, room_idx, piece) do
    case rooms |> Rooms.fetch!(room_idx) |> Room.add(piece) do
      {:ok, updated_room, cost} ->
        {cost, %{rooms | rooms: %{rooms.rooms | room_idx => updated_room}}}

      _ ->
        nil
    end
  end

  def print(hallway, rooms) do
    t = fn
      :empty -> "."
      a -> Atom.to_string(a)
    end

    a = hallway.positions |> Map.fetch!(1) |> t.()
    b = hallway.positions |> Map.fetch!(2) |> t.()
    c = hallway.positions |> Map.fetch!(4) |> t.()
    d = hallway.positions |> Map.fetch!(6) |> t.()
    e = hallway.positions |> Map.fetch!(8) |> t.()
    f = hallway.positions |> Map.fetch!(10) |> t.()
    g = hallway.positions |> Map.fetch!(11) |> t.()

    tx = fn room, n ->
      list = room.occupants
      dx = 4 - length(list)
      filler = List.duplicate(:empty, dx)
      list = filler ++ list
      Enum.at(list, n) |> t.()
    end

    r1a = rooms.rooms |> Map.fetch!(3) |> tx.(0)
    r1b = rooms.rooms |> Map.fetch!(3) |> tx.(1)
    r1c = rooms.rooms |> Map.fetch!(3) |> tx.(2)
    r1d = rooms.rooms |> Map.fetch!(3) |> tx.(3)

    r2a = rooms.rooms |> Map.fetch!(5) |> tx.(0)
    r2b = rooms.rooms |> Map.fetch!(5) |> tx.(1)
    r2c = rooms.rooms |> Map.fetch!(5) |> tx.(2)
    r2d = rooms.rooms |> Map.fetch!(5) |> tx.(3)

    r3a = rooms.rooms |> Map.fetch!(7) |> tx.(0)
    r3b = rooms.rooms |> Map.fetch!(7) |> tx.(1)
    r3c = rooms.rooms |> Map.fetch!(7) |> tx.(2)
    r3d = rooms.rooms |> Map.fetch!(7) |> tx.(3)

    r4a = rooms.rooms |> Map.fetch!(9) |> tx.(0)
    r4b = rooms.rooms |> Map.fetch!(9) |> tx.(1)
    r4c = rooms.rooms |> Map.fetch!(9) |> tx.(2)
    r4d = rooms.rooms |> Map.fetch!(9) |> tx.(3)

    """
     #############
     ##{a}#{b}.#{c}.#{d}.#{e}.#{f}#{g}#
     ####{r1a}##{r2a}##{r3a}##{r4a}###
       ##{r1b}##{r2b}##{r3b}##{r4b}#
       ##{r1c}##{r2c}##{r3c}##{r4c}#
       ##{r1d}##{r2d}##{r3d}##{r4d}#
       #########
    """
  end
end
