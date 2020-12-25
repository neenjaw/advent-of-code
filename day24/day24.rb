# frozen_string_literal: true

ALL_DIRECTIONS = %w[nw ne e se sw w].freeze

def move(direction, coordinate)
  x, y, z = coordinate

  case direction
  when 'w'
    [x - 1, y + 1, z]
  when 'nw'
    [x, y + 1, z - 1]
  when 'ne'
    [x + 1, y, z - 1]
  when 'e'
    [x + 1, y - 1, z]
  when 'se'
    [x, y - 1, z + 1]
  when 'sw'
    [x - 1, y, z + 1]
  else
    raise "unhandled direction: #{direction}"
  end
end

def flip(grid, coordinate)
  case grid[coordinate]
  when nil
    grid[coordinate] = :black
  when :black
    grid[coordinate] = :white
  when :white
    grid[coordinate] = :black
  else
    raise "unhandled tile: #{grid[coordinate]}"
  end
  grid
end

def populate_grid(grid)
  grid
    .entries
    .filter { |_, colors| colors.first == :black }
    .each do |position, _|
      ALL_DIRECTIONS.each do |direction|
        adjacent_tile_position = move(direction, position)

        grid[adjacent_tile_position] = %i[white white] if grid[adjacent_tile_position].nil?
      end
    end
end

tile_instructions = File.read(ARGV[0]).chomp.split("\n").map do |line|
  # e, se, sw, w, nw, and ne
  line
    .chars
    .each_with_object({pending: nil, sequence: []}) do |c, memo|
      case c
      when 'n', 's'
        memo[:pending] = c
      when 'e', 'w'
        if memo[:pending]
          memo[:sequence] << (memo[:pending] << c)
          memo[:pending] = nil
        else
          memo[:sequence] << c
        end
      else
        raise "unhandled direction #{c}"
      end
    end
    .then { |memo| memo[:sequence] }
end

grid_result =
  tile_instructions
  .reduce({}) do |grid, sequence|
    coordinate = sequence.reduce([0, 0, 0]) do |position, direction|
      move(direction, position)
    end

    flip(grid, coordinate)
  end
  .values
  .count { |color| color == :black }

puts "Part 1: #{grid_result}"

conway_grid =
  tile_instructions
  .reduce({}) do |grid, sequence|
    coordinate = sequence.reduce([0, 0, 0]) do |position, direction|
      move(direction, position)
    end

    flip(grid, coordinate)
  end

conway_grid
  .entries
  .each do |position, color|
    conway_grid[position] = [color, color]
  end

100.times do
  populate_grid(conway_grid)

  conway_grid
    .entries
    .each do |position, colors|
      adjacent_black_tiles =
        ALL_DIRECTIONS
        .map { |direction| move(direction, position) }
        .map { |adjacent_position| conway_grid[adjacent_position] }
        .compact
        .count { |adj_colors| adj_colors.first == :black }

      case colors.first
      when :black
        conway_grid[position][1] = :white if adjacent_black_tiles.zero? || adjacent_black_tiles > 2
      when :white
        conway_grid[position][1] = :black if adjacent_black_tiles == 2
      end
    end

  conway_grid
    .entries
    .each do |position, (_old, new)|
      conway_grid[position] = [new, new]
    end
end

conway_result =
  conway_grid
  .values
  .count { |colors| colors.first == :black }

puts "Conway result: #{conway_result}"
