require "set"
require 'pqueue'
require 'pry'
require 'memoist'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

puts "file: #{file}"

board = File.read(file).split("\n").each_with_index.map do |line, y|
  line.chars.each_with_index.map do |char, x|
    [[y, x], char]
  end
end.flatten(1).to_h

START = "S"
FINISH = "E"
WALL = "#"
EMPTY = "."

wall_board = board.select { |_, v| v == WALL }.to_h

START_POINT = board.find { |_, v| v == START }.first
FINISH_POINT = board.find { |_, v| v == FINISH }.first


def neighbors
  [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0]
  ]
end

def print_grid(grid, path_points)
  ymin, ymax = grid.keys.map(&:first).minmax
  xmin, xmax = grid.keys.map(&:last).minmax

  (ymin..ymax).each do |y|
    (xmin..xmax).each do |x|
      point = [y, x]
      print path_points[point] || grid[point]
    end
    puts
  end
end

def interpolate_points_between(a, b)
  points = []
  y1, x1 = a
  y2, x2 = b

  dy =
    if y1 < y2
      1
    elsif y1 > y2
      -1
    else
      0
    end
  dx =
    if x1 < x2
      1
    elsif x1 > x2
      -1
    else
      0
    end

  y = y1 + dy
  x = x1 + dx

  while [y, x] != b
    points << [y, x]

    y += dy
    x += dx
  end

  # puts "a #{a}, b #{b}, points: #{points}"

  points
end

def find_distances(grid, start, finish, step = false)
  queue = PQueue.new { |a, b| a.last < b.last }
  queue.push([{node: finish, cost: 0}, 0])
  visited = {finish => 0}

  while !queue.empty?
    elem, _ = queue.pop
    node, cost = elem[:node], elem[:cost]
    y, x = node

    neighbors().each do |(dy, dx)|
      new_node = [y + dy, x + dx]

      print_grid(grid, { node => "O", new_node => "?" }) if step
      gets if step

      next if grid[new_node].nil?
      next if grid[new_node] == WALL

      new_cost = cost + 1

      next if visited[new_node] && visited[new_node] <= new_cost

      visited[new_node] = new_cost
      queue.push([{node: new_node, cost: new_cost}, new_cost])
      puts "Queue: #{queue.to_a}" if step
    end
  end

  puts "Visited: #{visited.inspect}"
  visited
end

def search_phase(grid, source, distances, max_distance)
  visited = Set.new
  shortcuts = {}
  queue = [{node: source, distance: 0}]

  while !queue.empty?
    elem = queue.shift
    node, distance = elem[:node], elem[:distance]
    y, x = node

    # if node == [7,3]
    #   puts "Node: #{node}, Distance: #{distance}"
    #   puts "Node Distance: #{distances[node]}, Source Distance: #{distances[source]}"
    #   puts "Gain: #{distances[source] - distances[node] - distance}"
    #   gets
    # end

    if distances[node] && distances[node] + distance < distances[source]
      gain = distances[source] - distances[node] - distance
      shortcuts[[source, node]] = {gain: gain, distance: distances[source] - gain}
    end

    # puts "Visited: #{visited.size}, queue: #{queue.size}, node: #{node}, distance: #{distance}"

    neighbors().each do |(dy, dx)|
      new_node = [y + dy, x + dx]

      next if grid[new_node].nil?
      next if visited.include?(new_node)
      visited.add(new_node)

      new_distance = distance + 1
      next if new_distance > max_distance

      queue << {node: new_node, distance: distance + 1}
    end
  end

  shortcuts
end

def count_cheat_paths(grid, cheat_type = :wall_jump, distances, start, finish)
  counts = {}

  wall_board = grid.select { |_, v| v == WALL }.to_h

  queue = PQueue.new { |a, b| a.last < b.last }
  queue.push([{node: start}, 0])

  while !queue.empty?
    elem, _ = queue.pop
    node = elem[:node]
    y, x = node

    puts "Node: #{node}"

    if cheat_type == :phase_20
      counts.merge!(search_phase(grid, node, distances, 20))
    end

    neighbors().each do |(dy, dx)|
      new_node = [y + dy, x + dx]

      next if grid[new_node].nil?

      if grid[new_node] == WALL
        if cheat_type == :wall_jump
          other_side = [y + dy * 2, x + dx * 2]
          next if grid[other_side].nil? || grid[other_side] == WALL
          next if distances[other_side] > distances[node]
          gain = distances[node] - distances[other_side] - 2

          puts "Node: #{node}, New Node: #{new_node}, Other Side: #{other_side}, Gain: #{gain}"
          puts "Distances: #{distances[node]} - #{distances[other_side]} - 2 = #{distances[node] - distances[other_side] - 2}"
          # print_grid(grid, { node => "O", new_node => "W", other_side => "D" })
          # gets

          counts[[node, other_side]] = {gain: gain, distance: distances[start] - gain}
        end
      else
        next if distances[new_node] > distances[node]
        queue.push([{node: new_node}, 0])
      end
    end
  end

  counts
end

distance_map = find_distances(board, START_POINT, FINISH_POINT, false)
p1_counts = count_cheat_paths(board, :wall_jump, distance_map, START_POINT, FINISH_POINT)
p1_groups = p1_counts.group_by { |k, v| v[:gain] }
p1_freqs = p1_groups.map { |k, v| [k, v.size] }.sort
p1_count = p1_freqs.select { |k, v| k >= 100 }.sum(&:last)
puts "Part 1: #{p1_counts}\n\n#{p1_groups}\n\n#{p1_freqs}\n\n#{p1_count}"

p2_counts = count_cheat_paths(board, :phase_20, distance_map, START_POINT, FINISH_POINT)
p2_groups = p2_counts.group_by { |k, v| v[:gain] }
p2_freqs = p2_groups.map { |k, v| [k, v.size] }.sort_by(&:first)

# p2_freqs.each do |k, v|
#   puts " - There are #{v} paths that save #{k} picoseconds" if k >= 50
# end

p2_count = p2_freqs.select { |k, v| k >= 100 }.sum(&:last)
puts "Part 2: #{p2_count}"
