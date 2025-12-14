class Solution
  START = "S"
  SPLITTER = "^"
  SPACE = "."
  BEAM = "|"

  attr_reader :input_data, :lines, :grid_map, :split_count

  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.chomp.split("\n")
    @grid_map = parse_grid
    @split_count = 0
  end

  # Standard AoC methods
  def part1
    simulate_beam
    split_count
  end

  def part2
    simulate_beam

    in_degree = Hash.new(0)
    paths_to_point = Hash.new(0)
    queue = []

    def get_neighbors(point)
      case grid_map[point]
      in BEAM | START
        [below(point)]
      in SPLITTER unless grid_map[above(point)] == SPACE
        sides(point)
      else
        []
      end
    end

    grid_map.each do |point, c|
      get_neighbors(point).each do |n|
        in_degree[n] += 1
      end
    end

    start = find_start
    paths_to_point[start] = 1
    queue << start

    while !queue.empty?
      point = queue.shift

      get_neighbors(point).each do |neighbor|
        paths_to_point[neighbor] += paths_to_point[point]

        in_degree[neighbor] -= 1
        if in_degree[neighbor] == 0
          queue << neighbor
        end
      end
    end

    # print_grid do |p|
    #   [
    #     grid_map[p].to_s,
    #     paths_to_point[p].to_s.rjust(2),
    #     copy_in_degree[p].to_s,
    #     in_degree[p].to_s
    #   ].join(" ").ljust(10)
    # end

    y = range_y.last
    range_x.sum do |x|
      p = [y, x]
      next 0 if grid_map[p] != BEAM

      paths_to_point[p]
    end
  end

  private

  def parse_grid
    lines.flat_map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        [[y, x], char]
      end
    end.to_h
  end

  def find_start
    grid_map.find { |key, value| value == START }.first
  end

  def simulate_beam
    @split_count = 0

    grid_map.each do |point, char|
      case char
      when START, BEAM
        propagate_beam(point)
      end
    end
  end

  def propagate_beam(point)
    pbelow = below(point)

    case grid_map[pbelow]
    when SPACE
      update_grid(pbelow, BEAM)
    when SPLITTER
      split_beam(pbelow)
    end
  end

  def split_beam(point)
    pabove = above(point)
    return unless grid_map[pabove] == BEAM

    @split_count += 1

    sides(point).each do |pside|
      case grid_map[pside]
      when SPACE
        update_grid(pside, BEAM)
      end
    end
  end

  def range_y
    @max_y ||= grid_map.max_by { |key, _| key[0] }.first[0]

    0..@max_y
  end

  def range_x
    @max_x ||= grid_map.max_by { |key, _| key[1] }.first[1]

    0..@max_x
  end

  def above(point)
    y, x = point
    [y - 1, x]
  end

  def below(point)
    y, x, = point
    [y + 1, x]
  end

  def sides(point)
    y, x = point
    [
      [y, x-1],
      [y, x+1]
    ]
  end

  def update_grid(coord, char)
    @grid_map[coord] = char
  end

  def print_grid
    buffer = []

    range_y.each do |y|
      line = ""
      range_x.each do |x|
        line += if block_given?
            yield [y, x]
          else
            grid_map[[y, x]]
          end
      end
      buffer << line
    end

    max_length = buffer.map(&:length).max

    puts "-" * max_length
    puts buffer.join("\n")
    puts "-" * max_length
  end
end
