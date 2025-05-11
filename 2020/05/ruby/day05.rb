def row_num(code)
  code
  .gsub(/F/, '0')
  .gsub(/B/, '1')
  .to_i(2)
end

def seat_num(code)
  code
  .gsub(/R/, '1')
  .gsub(/L/, '0')
  .to_i(2)
end

def code_to_seat(code)
  row = code.chomp[0...-3]
  seat = code.chomp[-3..]
  [row, seat]
end

def seat_to_id(row, seat)
  row * 8 + seat
end

tickets =
  File
  .readlines('input.txt') # .take(1)
  .inject([]) do |seat_numbers, ticket|
    # puts ticket

    row, seat = code_to_seat(ticket)

    # puts row.inspect
    # puts seat.inspect

    rn = row_num(row)
    sn = seat_num(seat)

    # puts rn.inspect
    # puts sn.inspect

    seat_id = seat_to_id(rn, sn)

    seat_numbers << seat_id if rn != 0 && rn != 127
  end
  .sort

min = tickets.min
max = tickets.max

puts tickets
     .zip((min..max))
     .drop_while {|(seat, n)| seat == n }
     .take(1)[0][1]
