require "set"

files = [
  "example",
  "input"
]

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

data = files.map do |file|
  [file, File.readlines(file).map(&:chomp)]
end.to_h

example_answer = <<-ANSWER
  ......#....#
  ...#........
  ....#.....#.
  ..#.........
  .........#..
  .#..........
  ...#........
  #......#....
  ........#...
  ............
  ..........#.
  ..........#.
  ANSWER

grids = data.map do |file, lines|
  grid = lines.each_with_index.map do |line, y|
    line.chars.each_with_index.map do |char, x|
      [[y, x], char]
    end
  end
  .flatten(1)
  .to_h

  [file, grid]
end.to_h

grid = grids[file]

antennases = grids.map do |file, grid|
  x = grid
    .reduce(Hash.new { |h, k| h[k] = Set.new }) do |acc, (coord, char)|
      acc[char] << coord if char != "."
      acc
    end

  [file, x]
end
.to_h

antennas = antennases[file]

def find_antinodes_1(antenna_set)
  antenna_set.to_a.permutation(2)
    .map do |pair|
      p1, p2 = pair.sort
      y1, x1 = p1
      y2, x2 = p2

      dy = y2 - y1
      dx = x2 - x1

      anti_node_a = [y1 - dy, x1 - dx]
      anti_node_b = [y2 + dy, x2 + dx]
      [anti_node_a, anti_node_b]
    end
    .flatten(1)
end

antinodes1 = antennas.map do |char, coords|
  find_antinodes_1(coords)
end
.flatten(1)
.select do |coord|
  grid[coord]
end
.to_set

# puts antinodes.inspect
puts antinodes1.size


def find_antinodes_2(antenna_set, grid)
  antenna_set.to_a.permutation(2)
    .map do |pair|
      p1, p2 = pair.sort
      y1, x1 = p1
      y2, x2 = p2

      dy = y2 - y1
      dx = x2 - x1

      seq1 = (1..).lazy.map { |i| [y1 + dy * i, x1 + dx * i] }.take_while { |coord| grid[coord] }.to_a
      seq2 = (1..).lazy.map { |i| [y2 - dy * i, x2 - dx * i] }.take_while { |coord| grid[coord] }.to_a

      seq1 + seq2
    end
    .flatten(1)
end

antinodes2 = antennas.map do |char, coords|
  find_antinodes_2(coords, grid)
end
.flatten(1)
.to_set

puts antinodes2.size
