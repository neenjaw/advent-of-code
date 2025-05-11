require "set"

files = [
  "example",
  "input"
]

GUARD = "^"
WALL = "#"
EMPTY = "."
WALKED = "X"
WALKED_NS = "|"
WALKED_WE = "-"
WALKED_BOTH = "+"
OUT_OF_BOUNDS = "Z"
TIME_LOOPER = "O"

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

UP = [-1, 0]
DOWN = [1, 0]
LEFT = [0, -1]
RIGHT = [0, 1]

DIR = { ">" => RIGHT, "<" => LEFT, "v" => DOWN, "^" => UP }
TURN = { ">" => "v", "<" => "^", "v" => "<", "^" => ">" }

data = files.map do |file|
  [file, File.readlines(file).map(&:chomp)]
end.to_h

class Grid
  def initialize(grid)
    @grid = grid
  end

  def [](coord)
    y, x = coord
    return nil if y < 0 || x < 0
    @grid[y]&.[](x)
  end

  def []=(coord, value)
    y, x = coord
    @grid[y] ||= []
    @grid[y][x] = value
  end

  def to_s
    @grid.map { |row| row.join }.join("\n")
  end

  def find_starting_coord
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return [y, x] if cell == GUARD
      end
    end
  end

  def self.from_lines(lines)
    grid = lines.map { |row| row.split("") }
    Grid.new(grid)
  end
end

grids = data.map do |file, lines|
  grid = Grid.from_lines(lines)
  [file, grid]
end.to_h

def do_walk(grid, coord, x = nil)
  visited = Set.new
  d = grid[coord]

  while grid[coord] != nil
    return false if visited.include?([coord, d])
    visited << [coord, d]

    next_coord = [coord[0] + DIR[d][0], coord[1] + DIR[d][1]]
    next_cell = grid[next_coord]

    while next_cell == WALL || next_coord == x
      d = TURN[d]
      next_coord = [coord[0] + DIR[d][0], coord[1] + DIR[d][1]]
      next_cell = grid[next_coord]
    end

    coord = next_coord
  end

  visited.map(&:first).uniq
end

def walk(grid, coord)
  initial_visited = do_walk(grid, coord.dup)
  time_loopers = initial_visited
    .count do |c|
      next false if c == coord
      do_walk(grid, coord, c) == false
    end

  [initial_visited.size, time_loopers]
end

grid = grids[file]
starting_coord = grid.find_starting_coord

if part == 1
  ans, _ = walk(grid, starting_coord)

  puts ans
  exit
end

if part == 2
  _, ans = walk(grid, starting_coord)
  puts ans
  exit
end
