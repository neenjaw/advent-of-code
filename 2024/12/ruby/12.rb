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
    [[y, x], char]
  end
end
.flatten(1)
.to_h

def group_by_types(grid)
  visited = Set.new
  groups = []

  grid.keys.each do |pos|
    next if visited.include?(pos)
    group = {}
    visited.add(pos)
    group[pos] = grid[pos]
    queue = [pos]
    type = grid[pos]

    until queue.empty?
      current = queue.shift
      y, x = current
      [[y + 1, x], [y - 1, x], [y, x + 1], [y, x - 1]].each do |neighbour|
        next if visited.include?(neighbour)
        next if grid[neighbour] != type
        visited.add(neighbour)
        queue.push(neighbour)
        group[neighbour] = grid[neighbour]
      end
    end

    groups.push(group)
  end

  groups
end

def neighbours?(y1, x1, y2, x2)
  (y1 - y2).abs + (x1 - x2).abs == 1
end

def label_groups_with_perimeter(groups)
  groups.map do |group|
    points = group.keys
    perimeter = points.size * 4

    points.permutation(2).each do |(y1, x1), (y2, x2)|
      perimeter -= 1 if neighbours?(y1, x1, y2, x2)
    end

    { type: group.values.first, group: group, perimeter: perimeter, area: group.size, cost: group.size * perimeter }
  end
end

groups = group_by_types(grid)
labelled_groups = label_groups_with_perimeter(groups)

# puts groups.inspect
# puts labelled_groups.inspect

puts labelled_groups.map { |group| group[:cost] }.sum

def neighbours_clockwise(direction)
  case direction
  when '^' # left, up, right, down
    ['<', '^', '>', 'v']
  when '<'
    ['v', '<', '^', '>']
  when 'v'
    ['>', 'v', '<', '^']
  when '>'
    ['^', '>', 'v', '<']
  end
end

def turn_right(direction)
  neighbours_clockwise(direction)[2]
end

def advance(direction, point)
  y, x = point
  case direction
  when '^' then [y - 1, x]
  when '<' then [y, x - 1]
  when 'v' then [y + 1, x]
  when '>' then [y, x + 1]
  end
end

def neighbour(direction, point)
  y, x = point
  case direction
  when '^' then [y - 1, x]
  when '<' then [y, x - 1]
  when 'v' then [y + 1, x]
  when '>' then [y, x + 1]
  end
end

def choice(method, point, direction)
  case method
  when :turn_left then
    next_dir = neighbours_clockwise(direction)[0]
    next_point = neighbour(next_dir, point)
    [next_dir, next_point]
  when :advance then
    [direction, advance(direction, point)]
  when :turn_right then
    [turn_right(direction), point]
  end
end

def label_groups_with_sides (groups)
  groups.map do |group|
    points = group.keys

    sides = 0
    visited = Set.new
    point = points.min
    direction = '^'

    loop do
      visited << [point, direction]

      # puts '----'
      # puts "sides: #{sides}" if DEBUG
      # puts "group: #{group.keys.inspect}" if DEBUG
      # puts "current: #{point.inspect}, #{direction}" if DEBUG

      next_direction, next_point = [:turn_left, :advance, :turn_right]
        .map { |method| choice(method, point, direction) }
        .select { |(_, candidate)| group[candidate] }
        .first

      # puts "next: " + [next_point, next_direction].inspect if DEBUG

      sides += 1 if direction != next_direction
      break if visited.include?([next_point, next_direction])

      point = next_point
      direction = next_direction
    end

    { type: group.values.first, group: group, sides: sides, area: group.size, cost: group.size * sides }
  end
end

labelled_groups = label_groups_with_sides(groups)

# puts labelled_groups.map { |group| group.inspect }.join("\n") if DEBUG
puts labelled_groups.map { |group| group[:cost] }.sum


def label_grid_sides(groups)
  groups.map do |group|
    corners = group.keys.sum do |(y, x)|
      dir = {
        u: [y-1, x], d: [y+1, x], l: [y, x-1], r: [y, x+1],
        ul: [y-1, x-1], ur: [y-1, x+1], dl: [y+1, x-1], dr: [y+1, x+1]
      }.map{ |k, v| [k, group[v]] }.to_h

      corners = 0

      #outer corners
      corners += 1 if dir[:u].nil? && dir[:l].nil?
      corners += 1 if dir[:u].nil? && dir[:r].nil?
      corners += 1 if dir[:d].nil? && dir[:l].nil?
      corners += 1 if dir[:d].nil? && dir[:r].nil?

      #inner corners
      corners += 1 if dir[:u] && dir[:l] && dir[:ul].nil?
      corners += 1 if dir[:u] && dir[:r] && dir[:ur].nil?
      corners += 1 if dir[:d] && dir[:l] && dir[:dl].nil?
      corners += 1 if dir[:d] && dir[:r] && dir[:dr].nil?

      corners
    end

    sides = corners

    { type: group.values.first, group: group, sides: sides, area: group.size, cost: group.size * sides }
  end
end

grid_group_sides = label_grid_sides(groups)
puts grid_group_sides.map { |group| group[:cost] }.sum
