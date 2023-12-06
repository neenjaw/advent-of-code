# Time:      7  15   30
# Distance:  9  40  200

input = ARGF.read.chomp.split("\n")
  .map do |line|
    line.chomp.split.drop(1).map(&:to_i)
  end

races =
  input
  .transpose
  .map do |(time, distance_record)|
    wins = 0
    pause = 0

    while pause < time
      pause += 1
      distance = pause * (time - pause)
      wins += 1 if distance > distance_record
    end

    wins
  end
  .inject(&:*)

pp races

time, distance_record = input.map(&:join)
  .map(&:to_i)


min = 0
max = time
middle = (min + max) / 2
iterations = 0
win_start = -1

while min < max
  iterations += 1
  pause = middle
  prev_pause = pause - 1

  distance = pause * (time - pause)
  prev_distance = prev_pause * (time - prev_pause)

  if distance > distance_record && prev_distance <= distance_record
    win_start = pause
    break
  elsif prev_distance > distance_record
    max = middle - 1
  elsif distance <= distance_record
    min = middle + 1
  end
  middle = (min + max) / 2
end

pp win_start

min = 0
max = time
middle = (min + max) / 2
iterations = 0
win_end = -1

while min < max
  iterations += 1
  pause = middle
  next_pause = pause + 1

  puts "min: #{min}\nmax: #{max}\nmiddle: #{middle}\npause: #{pause}\nnext_pause: #{next_pause}"


  distance = pause * (time - pause)
  next_distance = next_pause * (time - next_pause)

  puts "distance: #{distance}\nnext_distance: #{next_distance}\n\n"

  if distance > distance_record && next_distance <= distance_record
    win_end = pause
    break
  elsif next_distance > distance_record
    min = middle + 1
  elsif distance <= distance_record
    max = middle - 1
  end
  middle = (min + max) / 2
end

if win_end == -1
  win_end = max
end

pp win_end

pp win_end - win_start + 1
