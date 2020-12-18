
class Cube
  VALID_STATES = %i[active inactive].freeze

  attr_reader :pending_state, :current_state

  def initialize(state = :inactive)
    raise ArgumentError, "invalid state #{state.inspect}" unless VALID_STATES.include?(state)

    @current_state = state
    @pending_state = nil
  end

  def pending=(state)
    raise ArgumentError, "invalid state #{state.inspect}" unless VALID_STATES.include?(state)

    @pending_state = state
  end

  def step
    @pending_state = @current_state if pending_state.nil?

    @current_state = pending_state
    @pending_state = nil
  end

  def active?
    current_state == :active
  end

  def self.from_char(char)
    Cube.new(to_atom(char))
  end

  def to_s
    active? ? '#' : '.'
  end

  def self.to_atom(char)
    case char
    when '.'
      :inactive
    when '#'
      :active
    else
      raise ArgumentError, 'unknown char'
    end
  end
end

class SpatialGrid
  attr_reader :space, :ranges

  def initialize()
    @space = {}
    @ranges = {}
  end

  def get(x:, y:, z:)
    return space[z][y][x] unless space[z].nil? || space[z][y].nil? || space[z][y][x].nil?

    put(x: x, y: y, z: z, cube: Cube.new)
    space[z][y][x]
  end

  def put(x:, y:, z:, cube:)
    update_ranges(z: z, y: y, x: x, cube: cube)

    space[z] ||= {}
    space[z][y] ||= {}
    space[z][y][x] = cube
  end

  def step
    dz = ranges[:z]
    dy = ranges[:y]
    dx = ranges[:x]

    dz.each do |z|
      dy.each do |y|
        dx.each do |x|
          count = count_nearby(z: z, y: y, x: x)
          cube = get(x: x, y: y, z: z)
          if cube.active? && !(2..3).cover?(count)
            make_inactive(x: x, y: y, z: z)
          elsif !cube.active? && count == 3
            make_active(x: x, y: y, z: z)
          end
        end
      end
    end

    dz.each do |z|
      dy.each do |y|
        dx.each do |x|
          get(x: x, y: y, z: z).step
        end
      end
    end
  end

  def to_s
    dz = ranges[:z]
    dy = ranges[:y]
    dx = ranges[:x]

    out = ''

    dz.each do |z|
      out << "z=#{z}\n"
      dy.each do |y|
        dx.each do |x|
          out << get(x: x, y: y, z: z).to_s
        end
        out << "\n"
      end
    end

    out
  end

  private

  def make_active(z:, y:, x:)
    get(x: x, y: y, z: z).pending = :active
  end

  def make_inactive(z:, y:, x:)
    get(x: x, y: y, z: z).pending = :inactive
  end

  def count_nearby(z:, y:, x:, state: :active)
    count = 0
    (-1..1).each do |dz|
      (-1..1).each do |dy|
        (-1..1).each do |dx|
          next if dz.zero? && dy.zero? && dx.zero?

          count += 1 if get(x: x + dx, y: y + dy, z: z + dz).active?
        end
      end
    end
    count
  end

  def update_ranges(z:, y:, x:, cube:)
    update_range(:z, z, cube)
    update_range(:y, y, cube)
    update_range(:x, x, cube)
  end

  def update_range(axis, n, cube)
    range = ranges[axis] || (n..n)
    next_start = range.begin
    next_end = range.end

    if cube.active?
      next_start = n - 1 if n <= next_start
      next_end = n + 1 if n >= next_end
    else
      next_start = n if n < next_start
      next_end = n if n > next_end
    end

    ranges[axis] = next_start..next_end
  end
end

input = File.read(ARGV[0]).chomp.split("\n").map{ |row| row.split('') }

# Set the initial grid
grid = SpatialGrid.new
input.each.with_index do |row, y|
  row.each.with_index do |cube, x|
    grid.put(x: x, y: y, z: 0, cube: Cube.from_char(cube))
  end
end

6.times { grid.step }

puts grid.to_s.chars.reduce(0) { |acc, char| char == '#' ? acc + 1 : acc }
