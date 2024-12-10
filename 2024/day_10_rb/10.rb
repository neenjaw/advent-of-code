require "set"

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

input = File.readlines(file).map(&:chomp)

grid = input.each_with_index.map do |line, y|
  line.chars.each_with_index.map do |char, x|
    e = char == "." ? -1 : char.to_i
    [[y, x], e]
  end
end
.flatten(1)
.to_h

# puts grid.inspect if DEBUG

trail_heads = grid.select { |_, char| char == 0 }.keys

# puts trail_heads.inspect if DEBUG

def get_neighbours(coord)
  y, x = coord
  [
    [y, x - 1],
    [y, x + 1],
    [y - 1, x],
    [y + 1, x]
  ]
end

def get_trail_score(grid, starting_point)
  points = 0
  queue = [starting_point]
  visited = Set.new

  until queue.empty?
    point = queue.shift
    next if visited.include?(point)
    visited << point

    y, x = point

    if grid[point] == 9
      points += 1
      next
    end

    current_elevation = grid[point]
    neighbours = get_neighbours(point)
    neighbours.each do |neighbour|
      next if grid[neighbour].nil?

      neighbour_elevation = grid[neighbour]
      next if current_elevation + 1 != neighbour_elevation

      queue << neighbour
    end
  end

  points
end

def get_trail_rating(grid, starting_point)
  points = 0
  queue = [starting_point]

  until queue.empty?
    point = queue.shift
    y, x = point

    if grid[point] == 9
      points += 1
      next
    end

    current_elevation = grid[point]
    neighbours = get_neighbours(point)
    neighbours.each do |neighbour|
      next if grid[neighbour].nil?

      neighbour_elevation = grid[neighbour]
      next if current_elevation + 1 != neighbour_elevation

      queue << neighbour
    end
  end

  points
end

trail_info = trail_heads.map do |trail_head|
  [trail_head, get_trail_score(grid, trail_head), get_trail_rating(grid, trail_head)]
end

trail_scores = trail_info.sum { |_, score, _| score }

puts trail_scores if DEBUG

trail_ratings = trail_info.sum { |_, _, rating| rating }

puts trail_ratings if DEBUG
