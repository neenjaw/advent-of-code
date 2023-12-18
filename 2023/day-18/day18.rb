require 'set'
require 'io/console'

def read
  parts = []
  ARGF.read.chomp.split("\n").each do |line|
    direction, amount_input, color = line.split()
    parts << [direction, amount_input.to_i, color]
  end
  parts
end

def print_lagoon(lagoon)
  min_y, max_y = lagoon.map(&:first).minmax
  min_x, max_x = lagoon.map(&:last).minmax

  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      if lagoon.include?([y, x])
        print '#'
      else
        print '.'
      end
    end
    puts ''
  end
end

def flood_fill(lagoon)
  lagoon = lagoon.dup

  y, x = lagoon.min_by { |y, x| [y, x] }

  queue = [[y + 1, x + 1]]
  while !queue.empty?
    coord = queue.shift

    [
      [coord[0] - 1, coord[1]],
      [coord[0] + 1, coord[1]],
      [coord[0], coord[1] - 1],
      [coord[0], coord[1] + 1],
    ].each do |coord|
      if !lagoon.include?(coord)
        lagoon << coord
        queue << coord
      end
    end
  end

  lagoon
end

DIRS = {
  'U' => [-1, 0],
  'D' => [1, 0],
  'L' => [0, -1],
  'R' => [0, 1]
}

ORD = {
  '0' => 'R',
  '1' => 'D',
  '2' => 'L',
  '3' => 'U'
}

instructions = read

lagoon = Set.new
instructions.inject([0, 0]) do |(y, x), (direction, amount, color)|
  dy, dx = DIRS[direction]
  amount.times do
    lagoon << [y, x]
    y += dy
    x += dx
  end
  [y, x]
end

min_y = lagoon.map(&:first).min
min_x = lagoon.map(&:last).min
shifted_lagoon = lagoon.map { |y, x| [y - min_y, x - min_x] }.to_set

scanned_lagoon = flood_fill(shifted_lagoon)

# print_lagoon(scanned_lagoon)

pp scanned_lagoon.size

points = [[0, 0]]
lines = []
lengths = []
instructions.inject([0, 0]) do |(y, x), (_direction, _amount, color)|
  dy, dx = DIRS[ORD[color[-2]]]
  real_amount = color[2..-3].to_i(16)

  p0 = [y, x]
  p1 = [y + (dy * real_amount), x + (dx * real_amount)]

  lengths << real_amount
  points << p1
  lines << [p0, p1]

  p1
end

inner_area =
  # points[0..-2].zip(points[1..])
  points.each_cons(2).inject(0) do |acc, ((y0, x0), (y1, x1))|
    acc + (y1 + y0) * (x1 - x0)
  end

perimeter = lengths.sum

area = (inner_area.abs / 2) + (perimeter / 2) + 1

pp area
