class Solution
  TP = "@"
  EMPTY = "."
  REMOVED = "X"

  attr_reader :input_data, :lines, :grid_map

  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.split("\n")
    @grid_map = parse_grid
  end

  # Standard AoC methods
  def part1
    find_removable.count
  end

  def part2
    loop do
      removable = find_removable
      break if removable.empty?

      removable.each do |coord, _|
        update_grid(coord, REMOVED)
      end
    end

    count(REMOVED)
  end

  private

  def parse_grid
    lines.flat_map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        [[y, x], char]
      end
    end.to_h
  end

  def update_grid(coord, char)
    @grid_map[coord] = char
  end

  def muts
    [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ]
  end

  def apply_mut(coord, mut)
    y, x, = coord
    dy, dx = mut

    [y + dy, x + dx]
  end

  def find_removable
    grid_map.filter do |coordinate, char|
      next if char == EMPTY || char == REMOVED

      surrounding = muts.count do |mut|
        grid_map[apply_mut(coordinate, mut)] == TP
      end

      surrounding < 4
    end
  end

  def count(needle)
    grid_map.count {|_, char| char == needle}
  end
end
