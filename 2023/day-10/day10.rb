# .....
# .S-7.
# .|.|.
# .L-J.
# .....

require 'set'

grid = []

ARGF.each_line do |line|
  grid << line.chomp.chars
end
# pp grid

def find_position(grid, target)
  grid.each_with_index do |row, y|
    row.each_with_index do |element, x|
      return [y, x] if element == target
    end
  end
  nil
end

position = find_position(grid, 'S')
puts "Position of 'S': #{position}" if position

def determine_start_char(position, grid)
  y, x = position

  has_top_connection = y > 0 && ['|', '7', 'F'].include?(grid[y - 1][x])
  has_bottom_connection = y < grid.size - 1 && ['|', 'J', 'L'].include?(grid[y + 1][x])
  has_left_connection = x > 0 && ['-', 'F', 'L'].include?(grid[y][x - 1])
  has_right_connection = x < grid[y].size - 1 && ['-', 'J', '7'].include?(grid[y][x + 1])

  if has_top_connection && has_bottom_connection && has_left_connection && has_right_connection
    raise '+'
  elsif has_bottom_connection && has_right_connection
    'F'
  elsif has_top_connection && has_left_connection
    'J'
  elsif has_left_connection && has_bottom_connection
    '7'
  elsif has_top_connection && has_right_connection
    'L'
  elsif has_top_connection && has_bottom_connection
    '|'
  elsif has_left_connection && has_right_connection
    '-'
  else
    raise '?'
  end
end

grid[position[0]][position[1]] = determine_start_char(position, grid)

pp grid[position[0]][position[1]]

# pp grid

def breadth_first_search(grid, position)
  visited = {}
  queue = [[position, 0]]

  while !queue.empty?
    current_position, current_distance = queue.shift
    y, x = current_position

    # Check if the current position is a valid node to visit
    if grid[y][x] != '.' && !visited.include?(current_position)
      visited[current_position] = current_distance

      char = grid[y][x]
      next_distance = current_distance + 1

      if char == 'F'
        queue << [[y, x + 1], next_distance] if x < grid[y].size - 1
        queue << [[y + 1, x], next_distance] if y < grid.size - 1
      elsif char == 'J'
        queue << [[y - 1, x], next_distance] if y > 0
        queue << [[y, x - 1], next_distance] if x > 0
      elsif char == '7'
        queue << [[y, x - 1], next_distance] if x > 0
        queue << [[y + 1, x], next_distance] if y < grid.size - 1
      elsif char == 'L'
        queue << [[y - 1, x], next_distance] if y > 0
        queue << [[y, x + 1], next_distance] if x < grid[y].size - 1
      elsif char == '|'
        queue << [[y - 1, x], next_distance] if y > 0
        queue << [[y + 1, x], next_distance] if y < grid.size - 1
      elsif char == '-'
        queue << [[y, x - 1], next_distance] if x > 0
        queue << [[y, x + 1], next_distance] if x < grid[y].size - 1
      else
        raise "Unknown char: #{char}"
      end
    end
  end

  return visited
end

visited = breadth_first_search(grid, position)

pp visited.values.max

filtered_grid = grid.map.with_index do |row, y|
  row.map.with_index do |char, x|
    if visited.include?([y, x])
      char
    else
      '.'
    end
  end
end

puts (filtered_grid.map(&:join).join("\n"))

super_sampled_grid = filtered_grid.map.with_index do |row, y|
  sampled_row =
    row.map do |char|
      case char
      when '.'
        [
          ['.', '.', '.'],
          ['.', '.', '.'],
          ['.', '.', '.'],
        ]
      when 'F'
        [
          ['.', '.', '.'],
          ['.', 'F', '-'],
          ['.', '|', '.'],
        ]
      when 'J'
        [
          ['.', '|', '.'],
          ['-', 'J', '.'],
          ['.', '.', '.'],
        ]
      when '7'
        [
          ['.', '.', '.'],
          ['-', '7', '.'],
          ['.', '|', '.'],
        ]
      when 'L'
        [
          ['.', '|', '.'],
          ['.', 'L', '-'],
          ['.', '.', '.'],
        ]
      when '|'
        [
          ['.', '|', '.'],
          ['.', '|', '.'],
          ['.', '|', '.'],
        ]
      when '-'
        [
          ['.', '.', '.'],
          ['-', '-', '-'],
          ['.', '.', '.'],
        ]
      else
        raise "Unknown char: #{char}"
      end
    end.transpose.map(&:flatten)
end.flatten(1)

puts (super_sampled_grid.map(&:join).join("\n"))

def find_starting_position(grid)
  grid.transpose.each_with_index do |column, x|
    column.each_with_index do |char, y|
      if char == '|'
        return [y, x+1]
      end
    end
  end
end

start_position = find_starting_position(super_sampled_grid)

pp start_position

def flood_fill(grid, point, target, replacement)
  # Can use bfs/dfs here, this is easy to write recursively
  x, y = point

  return if x < 0 || x >= grid.length || y < 0 || y >= grid[0].length || grid[x][y] != target

  grid[x][y] = replacement

  flood_fill(grid, [x - 1, y], target, replacement)
  flood_fill(grid, [x + 1, y], target, replacement)
  flood_fill(grid, [x, y - 1], target, replacement)
  flood_fill(grid, [x, y + 1], target, replacement)
end

flood_fill(super_sampled_grid, start_position, '.', 'I')

puts (super_sampled_grid.map(&:join).join("\n"))

def find_included_on_original(grid, super_sampled_grid, target = 'I')
  count = 0
  grid.each_with_index do |row, y|
    row.each_with_index do |char, x|
      mods = [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 0],
        [2, 1],
        [2, 2],
      ]

      scaled_y = y * 3
      scaled_x = x * 3

      if mods.all? { |mod| super_sampled_grid[scaled_y + mod[0]][scaled_x + mod[1]] == target }
        count += 1
      end
    end
  end
  count
end

puts find_included_on_original(grid, super_sampled_grid)
