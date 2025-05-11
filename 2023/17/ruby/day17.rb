require 'set'
require 'io/console'
require 'algorithms'
include Containers

def read
  parts = []
  ARGF.read.chomp.split("\n").each do |line|
    part = line.chars.map(&:to_i)
    parts << part
  end
  parts
end

def print_path(field, path)
  flattened_path = []
  while !path.nil?
    flattened_path << path.shift
    path = path[0]
  end

  h = flattened_path.reverse.each_with_index.to_h { |tile, index| [tile, index] }
  field.each_with_index do |row, y|
    row.each_with_index do |c, x|
      if h.key?([y, x])
        index = h[[y, x]]

        if index == 0
          print "X"
        else
          prev_y, prev_x = flattened_path[index - 1]

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

OPTIONS = [[[1, 0], :down], [[-1, 0], :up], [[0, 1], :right], [[0, -1], :left]].freeze

def bfs_min_heap(field:, start: [0, 0], destination: nil, min_dir_count: 1, max_dir_count: 3, dbg: false)
  destination ||= [field.length - 1, field[0].length - 1]

  memo = {}
  heap = MinHeap.new()
  heap.push(0, [0, [start, :none, 0, [start]]])
  result = Float::INFINITY
  result_path = []

  iter = 0
  while !heap.empty?
    iter += 1
    heat_loss, current = heap.pop

    coord, dir, dir_count, path = current
    # pp [coord, dir, dir_count, path]

    if memo.key?([coord, dir, dir_count])
      next
    else
      memo[[coord, dir, dir_count]] = heat_loss
    end


    if coord == destination
      if dir_count >= min_dir_count
        result = [result, heat_loss].min
        result_path = path
      end
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

      heap.push(next_heat_loss, [next_heat_loss, [next_coord, next_dir, next_dir_count, [next_coord, path]]])
    end

    if dbg
      pp heap
      puts "Press any key to continue"
      STDIN.getch
    end
  end


  [result, result_path]
end

grid = read

cost_a, path_a = bfs_min_heap(field: grid, start: [0, 0])
cost_b, path_b = bfs_min_heap(field: grid, start: [0, 0], min_dir_count: 4, max_dir_count: 10, dbg: false)

pp [cost_a, cost_b]

print_path(grid, path_a)
puts '-' * 80
print_path(grid, path_b)
