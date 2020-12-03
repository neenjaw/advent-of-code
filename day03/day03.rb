require 'benchmark'

# lines = <<~MAP
#   ..##.......
#   #...#...#..
#   .#....#..#.
#   ..#.#...#.#
#   .#...##..#.
#   ..#.##.....
#   .#.#.#....#
#   .#........#
#   #.##...#...
#   #...##....#
#   .#..#...#.#
# MAP

lines = File.readlines('input.txt')
lines = lines.map(&:chomp)

dx = 3
dy = 1

def run(dx:, dy:, map:)
  x = 0
  y = 0
  trees = 0

  lx = map[0].length

  while y < map.length - 1
    x += dx
    y += dy
    trees += 1 if map[y][x % lx] == '#'
  end

  trees
end

puts run(dx: dx, dy: dy, map: lines)

puts [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2]
]
  .map { |(dx, dy)| run(dx: dx, dy: dy, map: lines) }
  .inject(&:*)

# valids = 0

# Benchmark.bm do |x|
#   x.report do
#     valids = lines.count do |line|
#       PasswordPolicy.from_line(line).valid?
#     end
#   end
# end

# puts valids
