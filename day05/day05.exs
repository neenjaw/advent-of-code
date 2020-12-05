tickets = File.read!("input.txt") |> String.split("\n", trim: true)

row_num = fn row ->
  row
  |> String.replace("F", "0")
  |> String.replace("B", "1")
  |> String.to_integer(2)
end

seat_num = fn seat ->
  seat
  |> String.replace("R", "1")
  |> String.replace("L", "0")
  |> String.to_integer(2)
end

seat_id = fn row_num, seat_num -> row_num * 8 + seat_num end

tickets
|> Enum.map(fn ticket ->
  {row, seat} = String.split_at(ticket, -3)
  rn = row_num.(row)
  sn = seat_num.(seat)
  seat_id.(rn, sn)
end)
|> Enum.max()
|> IO.inspect(label: "part 1")

potential_seat_ids =
  tickets
  |> Enum.reduce([], fn ticket, acc ->
    {row, seat} = String.split_at(ticket, -3)
    rn = row_num.(row)
    sn = seat_num.(seat)

    cond do
      rn != 0 && rn != 127 -> [seat_id.(rn, sn) | acc]
      true -> acc
    end
  end)
  |> Enum.sort(:asc)

potential_min = hd(potential_seat_ids)

potential_seat_ids
|> Enum.with_index(potential_min)
|> Enum.drop_while(fn {seat, idx} ->
  seat == idx
end)
|> List.first()
|> elem(1)
|> IO.inspect(label: "part 2")
