require 'set'
require 'io/console'
require 'algorithms'
include Containers


# class MinHeap
#   def initialize(*elements)
#     @elements = [*elements]
#   end

#   def insert(*elements)
#     @elements += elements
#     sort_by_priority!
#   end

#   def extract
#     @elements.shift
#   end

#   def empty?
#     @elements.empty?
#   end

#   private

#   def sort_by_priority!
#     @elements.sort_by! { |priority, _| priority }
#   end
# end

def read
  parts = []
  ARGF.read.chomp.split("\n").each do |line|
    part = line.chars.map(&:to_i)
    parts << part
  end
  parts
end

def print_path(field, path)
  h = path.each_with_index.to_h { |tile, index| [tile, index] }
  field.each_with_index do |row, y|
    row.each_with_index do |c, x|
      if h.key?([y, x])
        index = h[[y, x]]

        if index == 0
          print "X"
        else
          prev_y, prev_x = path[index - 1]

          if prev_y < y
            print "\e[31mv\e[0m"
          elsif prev_y > y
            print "\e[31m^\e[0m"
          elsif prev_x < x
            print "\e[31m>\e[0m"
          elsif prev_x > x
            print "\e[31m<\e[0m"
          end
        end
      else
        print c
      end
    end
    puts ''
  end
end

def within_bounds?(field, tile)
  y, x = tile
  x >= 0 && y >= 0 && y < field.length && x < field[y].length
end

def arrived_at_end?(field, tile)
  y, x = tile

  y == field.length - 1 && x == field[0].length - 1
end

def bfs_traverse(field, start = [0, 0])
  solutions = {}
  memo = {}
  queue = [[start, [], Set.new, :none, 0, 0]]

  while !queue.empty?
    current = queue.shift
    tile, path, seen, dir, straight_count, acc_heat_loss = current

    if seen.include?(tile) || (!memo[tile].nil? && memo[tile][0] < acc_heat_loss)
      next
    end

    puts "Visiting #{tile} #{dir} #{acc_heat_loss} #{path.length}" if path.length % 10 == 0

    seen = seen.dup
    seen << tile
    path = path.dup
    path << tile

    memo[tile] = [acc_heat_loss, path]

    if arrived_at_end?(field, tile)
      final_heat_loss = acc_heat_loss - field[tile[0]][tile[1]]
      puts "Arrived at end with heat loss #{final_heat_loss}"
      solutions[acc_heat_loss] = path
      next
    end

    options = [[[1, 0], :down], [[-1, 0], :up], [[0, 1], :right], [[0, -1], :left]]
      .select do |(_, next_dir)|
        case dir
        when :none
          true
        when :up
          next_dir != :down
        when :down
          next_dir != :up
        when :left
          next_dir != :right
        when :right
          next_dir != :left
        end
      end
      .map { |((dy, dx), _)| [[tile[0] + dy, tile[1] + dx], _] }
      .select { |(next_tile, _)| within_bounds?(field, next_tile) }
      .select { |(next_tile, _)| !seen.include?(next_tile) }
      .map do |(next_tile, next_dir)|
        next_straight_count = dir == next_dir ? straight_count + 1 : 0

        heat_loss_to_enter_tile = field[next_tile[0]][next_tile[1]]
        next_heat_loss = acc_heat_loss + heat_loss_to_enter_tile

        [next_tile, path, seen, next_dir, next_straight_count, next_heat_loss]
      end
      .select { |(_, _, _, _, next_straight_count, _)| next_straight_count < 3 }
      .select { |(next_tile, _, _, _, _, next_heat_loss)| (memo[next_tile].nil? || memo[next_tile][0] > next_heat_loss) }
      .each { |option| queue << option }
  end

  [memo, solutions]
end

def is_backwards?(current_direction, next_direction)
  case current_direction
  when :none
    false
  when :up
    next_direction == :down
  when :down
    next_direction == :up
  when :left
    next_direction == :right
  when :right
    next_direction == :left
  end
end

def a_star(field, start = [0, 0], destination = nil)
  destination ||= [field.length - 1, field[0].length - 1]

  # Calculate the heuristic cost using Manhattan distance
  def heuristic_cost(current, destination)
    (current[0] - destination[0]).abs + (current[1] - destination[1]).abs
  end

  # Initialize the open and closed sets
  frontier_set = [[start, :none, 0]]
  explored_set = []

  # Initialize the cost and path dictionaries
  g_score = { start => 0 }
  f_score = { start => heuristic_cost(start, destination) }
  came_from = {}

  while !frontier_set.empty?
    # Find the node with the lowest f_score
    current, current_direction, current_straight_count = frontier_set.min_by { |(node, _, _)| f_score[node] }

    # If the current node is the destination, reconstruct the path and return it
    if current == destination
      path = [current]
      while came_from.key?(current)
        current = came_from[current]
        path.unshift(current)
      end
      # puts "Found path with heat loss #{sum_heat_loss(field, path)} with straight count #{current_straight_count}"
      return path
    end

    frontier_set.delete_if { |(node, _, _)| node == current }
    explored_set << current

    # Generate the neighbors of the current node
    neighbors = [
      [[current[0] + 1, current[1]], :down],
      [[current[0] - 1, current[1]], :up],
      [[current[0], current[1] + 1], :right],
      [[current[0], current[1] - 1], :left]
    ].select { |neighbor, _| within_bounds?(field, neighbor) }
    .select { |_, next_direction| !is_backwards?(current_direction, next_direction) }
    .select do |neighbor, _|
      p0_tile = current
      p1_tile = came_from[p0_tile]
      p2_tile = p1_tile && came_from[p1_tile]
      p3_tile = p2_tile && came_from[p2_tile]

      recent_path = [neighbor, p0_tile, p1_tile, p2_tile, p3_tile].compact
      recent_path.length < 5 || !(recent_path.map(&:first).uniq.length == 1 || recent_path.map(&:last).uniq.length == 1)
    end

    neighbors.each do |neighbor, direction|
      # Calculate the tentative g_score for the neighbor
      tentative_g_score = g_score[current] + field[neighbor[0]][neighbor[1]]

      if explored_set.include?(neighbor) && tentative_g_score >= g_score[neighbor]
        next
      end

      if !frontier_set.any? { |(node, _, _)| node == neighbor } || tentative_g_score < g_score[neighbor]
        came_from[neighbor] = current
        g_score[neighbor] = tentative_g_score
        f_score[neighbor] = g_score[neighbor] + heuristic_cost(neighbor, destination)

        if !frontier_set.any? { |(node, _, _)| node == neighbor }
          frontier_set << [neighbor, direction, 0]
        end
      end
    end
  end

  # If no path is found, return an empty array
  []
end

def sum_heat_loss(field, path)
  path.sum { |tile| field[tile[0]][tile[1]] }
end

OPTIONS = [[[1, 0], :down], [[-1, 0], :up], [[0, 1], :right], [[0, -1], :left]].freeze

def bfs_min_heap(field:, start: [0, 0], destination: nil, min_dir_count: 1, max_dir_count: 3, dbg: false)
  destination ||= [field.length - 1, field[0].length - 1]

  memo = {}
  heap = MinHeap.new()
  heap.push(0, [0, [start, :none, 0]])
  result = Float::INFINITY

  iter = 0
  while !heap.empty?
    iter += 1
    heat_loss, current = heap.pop

    if memo.key?(current)
      next
    else
      memo[current] = heat_loss
    end

    coord, dir, dir_count = current

    if coord == destination
      result = [result, heat_loss].min
      next
    end

    OPTIONS.each do |(dy, dx), next_dir|
      next_coord = [coord[0] + dy, coord[1] + dx]

      next if !within_bounds?(field, next_coord)
      next if is_backwards?(dir, next_dir)

      next_dir_count = dir == next_dir ? dir_count + 1 : 1

      next if dir == next_dir && next_dir_count > max_dir_count
      next if dir != :none && dir != next_dir && dir_count < min_dir_count

      next_heat_loss = heat_loss + field[next_coord[0]][next_coord[1]]

      heap.push(next_heat_loss, [next_heat_loss, [next_coord, next_dir, next_dir_count]])
    end

    if dbg
      pp heap
      puts "Press any key to continue"
      STDIN.getch
    end
  end

  result
end

grid = read

# memo, solutions = bfs_traverse(grid)

# pp grid

# # pp memo

# # destination = [grid.length - 1, grid[0].length - 1]

# # print_path(grid, memo[destination][1])

# # pp memo[destination][0]

# # pp solutions.keys.min - grid[destination[0]][destination[1]]

# a_path = a_star(grid, [0, 0], destination)
# pp a_path
# pp (sum_heat_loss(grid, a_path))
# print_path(grid, a_path)

# Notes for tomorrow:
# - A* can be faster than BFS, but i'm getting the wrong answer it is choosing the wrong path as the minimum cost
# - I think something is wrong with my memoization, because BFS is correct but too slow (not culling enough paths)
# - min heap impl works, but is very slow

pp bfs_min_heap(field: grid, start: [0, 0])
pp bfs_min_heap(field: grid, start: [0, 0], min_dir_count: 4, max_dir_count: 10, dbg: false)
