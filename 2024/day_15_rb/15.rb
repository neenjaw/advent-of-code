require "set"

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

grid_input, instructions = File.read(file).split("\n\n")

grid = grid_input.split("\n").each_with_index.map do |line, y|
  line.chars.each_with_index.map do |char, x|
    [[y, x], char]
  end
end
.flatten(1)
.to_h

def print_grid(grid)
  min_y, max_y = grid.keys.map(&:first).minmax
  min_x, max_x = grid.keys.map(&:last).minmax

  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      print grid[[y, x]] || "."
    end
    puts
  end
end


instructions = instructions.split("\n").join

print_grid(grid)

robot = grid.find { |_, v| v == "@" }.first

def direction_to_dydx(char)
  case char
  when "^"
    [-1, 0]
  when "v"
    [1, 0]
  when "<"
    [0, -1]
  when ">"
    [0, 1]
  end
end

def reverse_dydx(dydx)
  case dydx
  when [0, -1]
    [0, 1]
  when [0, 1]
    [0, -1]
  when [-1, 0]
    [1, 0]
  when [1, 0]
    [-1, 0]
  end
end

def apply_dydx(coord, dydx)
  [coord[0] + dydx[0], coord[1] + dydx[1]]
end

WALL = "#"
BARREL = "O"
SPACE = "."
ROBOT = "@"
LB = "["
RB = "]"

part1_grid = grid.dup
robot = part1_grid.find { |_, v| v == "@" }.first
instructions.chars.each_with_index do |char, i|
  dydx = direction_to_dydx(char)
  cursor = apply_dydx(robot, dydx)
  while [BARREL].include?(part1_grid[cursor])
    cursor = apply_dydx(cursor, dydx)
  end

  next if part1_grid[cursor] == WALL

  rdydx = reverse_dydx(dydx)
  while cursor != robot
    rcursor = apply_dydx(cursor, rdydx)
    part1_grid[cursor] = part1_grid[rcursor]
    part1_grid[rcursor] = SPACE
    cursor = rcursor
  end

  robot = apply_dydx(robot, dydx)
end

p1 = part1_grid.select { |_, v| v == BARREL }.keys.map { |y, x| 100 * y + x }.sum
puts p1

print_grid(grid)
wide_grid = grid.dup.inject({}) do |acc, (coord, char)|
  y, x = coord
  case char
  when ROBOT
    acc[[y, 2*x]] = ROBOT
    acc[[y, 2*x + 1]] = SPACE
  when WALL
    acc[[y, 2*x]] = WALL
    acc[[y, 2*x + 1]] = WALL
  when BARREL
    acc[[y, 2*x]] = LB
    acc[[y, 2*x + 1]] = RB
  when SPACE
    acc[[y, 2*x]] = SPACE
    acc[[y, 2*x + 1]] = SPACE
  end

  acc
end

print_grid(wide_grid)
robot = wide_grid.find { |_, v| v == ROBOT }.first

instructions.chars.each_with_index do |char, i|
  print_grid(wide_grid) if DEBUG
  puts "char: #{char}" if DEBUG

  dydx = direction_to_dydx(char)

  lookahead = [[robot]]
  if ['<', '>'].include?(char)
    cursor = apply_dydx(robot, dydx)
    until [WALL, SPACE].include?(wide_grid[cursor])
      lookahead << [cursor]
      cursor = apply_dydx(cursor, dydx)
    end
    lookahead << [cursor]
  else # ['^', 'v'].include?(char)
    until lookahead.last.any? { |p| wide_grid[p] == WALL } || lookahead.last.all? { |p| wide_grid[p] == SPACE }
      layer = []
      lookahead.last.each do |coord|
        next if wide_grid[coord] == SPACE
        cursor = apply_dydx(coord, dydx)
        if wide_grid[cursor] == LB
          layer << cursor
          y, x = cursor
          cursor = [y, x + 1]
          layer << cursor
        elsif wide_grid[cursor] == RB
          layer << cursor
          y, x = cursor
          cursor = [y, x - 1]
          layer << cursor
        else
          layer << cursor
        end
      end
      lookahead << layer.uniq
    end
  end

  puts "lookahead: #{lookahead}" if DEBUG

  next if lookahead.last.any? { |p| wide_grid[p] == WALL }

  until lookahead.empty?
    layer = lookahead.pop
    layer.each do |coord|
      next if wide_grid[coord] == SPACE

      wide_grid[apply_dydx(coord, dydx)] = wide_grid[coord]
      wide_grid[coord] = SPACE
    end
  end

  robot = apply_dydx(robot, dydx)
end

p2 = wide_grid.select { |_, v| v == LB }.keys.map { |y, x| 100 * y + x }.sum
puts p2
