require 'set'
require 'io/console'

def read
  lines = []
  ARGF.read.chomp.split("\n").each_with_index do |line, idx|
    lines << line.chars
  end
  lines
end

def is_at_intersection(map, pos)
  y, x = pos
  around = [[-1, 0, :up], [1, 0, :down], [0, -1, :left], [0, 1, :right]]
    .map { |(dy, dx, dir)| [y + dy, x + dx, dir]}
    .select { |(ay, ax, dir)| ay >= 0 && ay < map.size && ax >= 0 && ax < map[0].size }
    .map do |(ay, ax, dir)|
      [dir, map[ay][ax] == '#']
    end
    .to_h

  count = around.values.count(true)
  only_horizontal = around[:left] && around[:right] && !around[:up] && !around[:down]
  only_vertical = around[:up] && around[:down] && !around[:left] && !around[:right]

  count < 2 && !only_horizontal && !only_vertical
end

def bfs_longest_path(map, in_pos, out_pos, slope = true, dbg = false)
  solution_sets = []
  queue = [[in_pos, 0, Set.new, Set.new]]
  max = -1
  while !queue.empty?
    pos, steps, visited, intersections = queue.shift
    pp pos, steps if dbg
    at_intersection = is_at_intersection(map, pos)
    visited << pos
    intersections << pos if at_intersection

    if pos == out_pos
      max = steps if steps > max
      solution_sets << [visited, intersections]
      next
    end

    y, x = pos
    puts "y: #{y}, x: #{x}" if dbg
    [[[y-1,x], :up], [[y+1,x], :down], [[y, x-1], :left], [[y,x+1], :right]].each do |(new_pos, direction)|
      puts "new_pos: #{new_pos}, direction: #{direction}" if dbg
      puts "map[new_pos[0]][new_pos[1]]: #{map[new_pos[0]][new_pos[1]]}" if dbg
      puts "visited.include?(new_pos): #{visited.include?(new_pos)}" if dbg
      next if visited.include?(new_pos)
      next if map[new_pos[0]][new_pos[1]] == '#'
      next if slope && map[new_pos[0]][new_pos[1]] == '^' && direction != :up
      next if slope && map[new_pos[0]][new_pos[1]] == 'v' && direction != :down
      next if slope && map[new_pos[0]][new_pos[1]] == '<' && direction != :left
      next if slope && map[new_pos[0]][new_pos[1]] == '>' && direction != :right

      new_visited = at_intersection ? visited.dup : visited
      new_intersections = at_intersection ? intersections.dup : intersections
      queue << [new_pos, steps + 1, new_visited, new_intersections]
    end
  end
  [max, solution_sets]
end

def reverse_direction(direction)
  case direction
  when :up
    :down
  when :down
    :up
  when :left
    :right
  when :right
    :left
  end
end

def bfs_find_segments(map, input, output, dbg = false)
  intersections = Set.new([input, output])
  segments = Hash.new { |h, k| h[k] = Hash.new }

  # find all intersections
  map.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if cell != '#' && is_at_intersection(map, [y, x])
        intersections << [y, x]
      end
    end
  end

  visited = Set.new
  queue = [[input, 0, input]]
  while !queue.empty?
    pos, steps, last_intersection = queue.shift
    # pp pos

    visited << pos
    next if pos == output

    y, x = pos
    [[[y-1,x], :up], [[y+1,x], :down], [[y,x-1], :left], [[y,x+1], :right]].each do |((y, x), dir)|
      next if y < 0 || y >= map.size || x < 0 || x >= map[0].size
      next if map[y][x] == '#'

      next_pos = [y, x]
      next_step = steps + 1
      next_last_intersection = last_intersection
      next_is_new_segment = false

      if next_pos != last_intersection && intersections.include?(next_pos)
        i1, i2 = [last_intersection, next_pos].minmax

        prev_segment_length = [(segments[i1][i2] || -1), (segments[i2][i1] || -1)].max
        is_longer = next_step > prev_segment_length

        segments[i1][i2] = next_step if is_longer
        segments[i2][i1] = next_step if is_longer

        next_last_intersection = next_pos
        next_step = 0
        next_is_new_segment = true
      end

      next if visited.include?(next_pos)

      if next_is_new_segment
        queue.push([next_pos, next_step, next_last_intersection])
      else
        queue.unshift([next_pos, next_step, next_last_intersection])
      end
    end
  end
  segments
end


def print_map(map, solution_set, intersections)
  map.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if intersections.include?([y, x])
        print "\e[32m+\e[0m"
      elsif solution_set.include?([y, x])
        print "\e[31mo\e[0m"
      else
        print cell
      end
    end
    print "\n"
  end
end

def bfs_longest_segment_path(segments, input, output)
  max = -1
  queue = [[input, 0, Set.new]]
  while !queue.empty?
    pos, steps, visited = queue.shift
    visited << pos

    if pos == output
      max = steps if steps > max
      pp [max, queue.size]
      next
    end

    segments.filter { |i1_key, i2_map| i1_key == pos }
      .each do |i1_key, i2_map|
        i2_map.each do |i2_key, segment_steps|
          next_pos = i2_key
          next if visited.include?(next_pos)

          next_steps = steps + segment_steps
          next_visited = visited.dup
          queue << [next_pos, next_steps, next_visited]
        end
      end
  end

  max
end

map = read

START = [0, 1]
EXIT = [map.size - 1, map[0].size - 2]

max, solutions = bfs_longest_path(map, START, EXIT)

# solutions.each do |(solution, intersections)|
#   puts "\n\n"
#   print_map(map, solution, intersections)
#   print "Steps: #{solution.size - 1}\n"
# end
puts "Part 1: #{max}"

# print_map(map, Set.new, Set.new)

segments = bfs_find_segments(map, START, EXIT, false)
pp segments

max = bfs_longest_segment_path(segments, START, EXIT)

# max, solutions = bfs_longest_path(map, START, EXIT, false)
# solutions.each do |(solution, intersections)|
#   puts "\n\n"
#   print_map(map, solution, intersections)
#   print "Steps: #{solution.size - 1}\n"
# end
puts "Part 2: #{max}"
