require "set"
require 'pqueue'
require 'pry'

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

grid = File.read(file).split("\n").each_with_index.map do |line, y|
  line.chars.each_with_index.map do |char, x|
    [[y, x], char]
  end
end
.flatten(1)
.to_h

def print_grid(grid, current_node = nil)
  min_y, max_y = grid.keys.map(&:first).minmax
  min_x, max_x = grid.keys.map(&:last).minmax

  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      if current_node == [y, x]
        print "O"
        next
      end

      print grid[[y, x]] || "."
    end
    puts
  end
end

START = grid.find { |_, v| v == "S" }.first
FINISH = grid.find { |_, v| v == "E" }.first

WALL = "#"
SPACE = "."

def neighbour_cost(dir, neighbour_dir)
  return 1 if dir == neighbour_dir
  1001
end

def invert_direction(dir)
  case dir
  when :n then :s
  when :s then :n
  when :w then :e
  when :e then :w
  end
end

def neighbours(node, current_direction)
  y, x = node
  [
    [[y - 1, x], :n, neighbour_cost(current_direction, :n)],
    [[y + 1, x], :s, neighbour_cost(current_direction, :s)],
    [[y, x - 1], :w, neighbour_cost(current_direction, :w)],
    [[y, x + 1], :e, neighbour_cost(current_direction, :e)],
  ].select { |(_, d, _)| d != invert_direction(current_direction) }
end

def shortest_path(grid)
  distances = Hash.new(Float::INFINITY)
  distances[START] = 0
  previous = {}
  queue = PQueue.new { |a, b| a.last < b.last }
  queue.push([START, :e, 0])

  while !queue.empty?
    current_node, direction, cost = queue.pop

    # find neighbours
    neighbours(current_node, direction).each do |(neighbour, new_direction, cost)|
      # skip if wall
      next if grid[neighbour] == WALL

      # calculate new distance
      new_distance = distances[current_node] + cost

      # if new distance is shorter than previous distance
      if new_distance < distances[neighbour]
        distances[neighbour] = new_distance
        previous[neighbour] = current_node
        queue.push([neighbour, new_direction, new_distance])
      end
    end
  end

  path = []
  current_node = FINISH
  while current_node
    path.unshift(current_node)
    current_node = previous[current_node]
  end

  return path, distances[FINISH]
end

p1 = shortest_path(grid)
puts "Part 1: #{p1.inspect}"

def apply_dir(coord, dir)
  y, x = coord
  case dir
  when :n then [y - 1, x]
  when :s then [y + 1, x]
  when :w then [y, x - 1]
  when :e then [y, x + 1]
  end
end

def turn_left(dir)
  case dir
  when :n then :w
  when :s then :e
  when :w then :s
  when :e then :n
  end
end

def turn_right(dir)
  case dir
  when :n then :e
  when :s then :w
  when :w then :n
  when :e then :s
  end
end

# This was nicer, but now its just a brute force
def all_shortest_paths(grid)
  queue = PQueue.new { |a, b| a.last < b.last }
  queue.push([[START], :e, 0])

  min = Float::INFINITY
  best = Set.new
  seen = {}

  while !queue.empty?
    path, dir, cost = queue.pop

    # Since we are uisng a priority queue, all of the shortest paths will be found first
    # So when they are found, we add them to the best set
    # When we start getting longer paths, we have see all the points, finish
    if path.last == FINISH
      if cost <= min
        min = cost
      else
        return best.size
      end
      best.merge(path)
    end

    next if !seen[[path.last, dir]].nil? && seen[[path.last, dir]] < cost
    seen[[path.last, dir]] = cost


    if grid[apply_dir(path.last, dir)] != '#'
        queue.push([path + [apply_dir(path.last, dir)], dir, cost + 1])
    end
    queue.push([path, turn_left(dir), cost + 1000])
    queue.push([path, turn_right(dir), cost + 1000])
  end

  # pp paths

  return 0
end

p2 = all_shortest_paths(grid)
puts "Part 2: #{p2.inspect}"
