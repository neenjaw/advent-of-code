require "set"
require 'pqueue'
require 'pry'

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

dimensions = file == "example" ? 0..6 : 0..70

points = File.read(file).split("\n").map do |line|
  x, y = line.split(",").map(&:to_i)
  [y, x]
end

blank_grid = dimensions.map do |y|
  dimensions.map do |x|
    [[y, x], '.']
  end
end
.flatten(1)
.to_h

bytes_to_take = file == "example" ? 12 : 1024

grid = points.take(bytes_to_take).reduce(blank_grid) do |acc, point|
  acc[point] = '#'
  acc
end

START = [dimensions.begin, dimensions.begin]
FINISH = [dimensions.end, dimensions.end]

puts "START: #{START} FINISH: #{FINISH}"

def shortest_path(grid, start, finish)
  distances = Hash.new(Float::INFINITY)
  distances[start] = 0
  previous = {}
  queue = PQueue.new { |a, b| a.last < b.last }
  queue.push([start, 0])

  while !queue.empty?
    current_node, cost = queue.pop

    # find neighbours
    [[0, 1], [0, -1], [1, 0], [-1, 0]].each do |(dy, dx)|
      # skip if wall
      neighbour = [current_node.first + dy, current_node.last + dx]
      next if grid[neighbour].nil? || grid[neighbour] == '#'

      # calculate new distance
      new_distance = distances[current_node] + 1

      # if new distance is shorter than previous distance
      if new_distance < distances[neighbour]
        distances[neighbour] = new_distance
        previous[neighbour] = current_node
        queue.push([neighbour, new_distance])
      end
    end
  end

  path = []
  current_node = finish
  while current_node
    path.unshift(current_node)
    current_node = previous[current_node]
  end

  return path, distances[finish]
end

def print_grid(grid, path_points)
  ymin, ymax = grid.keys.map(&:first).minmax
  xmin, xmax = grid.keys.map(&:last).minmax

  (ymin..ymax).each do |y|
    (xmin..xmax).each do |x|
      point = [y, x]
      print path_points.include?(point) ? 'O' : grid[point]
    end
    puts
  end
end

p1 = shortest_path(grid, START, FINISH)
print_grid(grid, p1.first)
puts "Part 1: #{p1.last}"

x = 0
loop do
  grid = points.take(x).reduce(blank_grid) do |acc, point|
    acc[point] = '#'
    acc
  end
  p = shortest_path(grid, START, FINISH)
  puts "p: #{x}, #{p.last}"
  if p.last == Float::INFINITY
    puts "Part 2: #{x}"
    break
  end
  x += 1
end

puts points.take(x).last.inspect
