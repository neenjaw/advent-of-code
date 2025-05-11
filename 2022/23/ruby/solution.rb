require 'set'

$dbg = false

class Solution
  ELF = '#'

  attr_accessor :input, :considerations, :round, :final

  def initialize(input)
    @input = input.chomp
      .split("\n")
      .each_with_index.reduce(Hash.new) do |memo, (line, y)|
        line.chars.each_with_index.reduce(memo) do |memo, (c, x)|
          memo[[y, x]] = c if c == ELF
          memo
        end
      end

    @considerations = [:N, :S, :W, :E]
    @round = 0
    @final = false
  end

  def play(n)
    n.times do
      step

      out if $dbg
      puts "----------------" if $dbg
    end

    self
  end

  def stable
    loop do
      result = step

      return round if result == :nothing

      out if $dbg
      p self if $dbg
      p self.count_empty if $dbg
      puts "----------------" if $dbg
    end
  end

  def step
    p [:step, round, considerations] if $dbg
    p [:moves, consider_moves] if $dbg

    @round += 1 if not final

    moves = consider_moves
    if moves.empty?
      @final = true
      return :nothing
    end

    moves.each do |pos, elves|
      p [:possible, pos, elves] if $dbg
      next if elves.size > 1

      input.delete(elves.first)
      input[pos] = ELF
    end

    rotate_considerations
  end

  def rotate_considerations
    prev = considerations.shift
    considerations << prev
    self
  end

  def consider_moves
    input.keys.reduce(Hash.new) do |memo, elf|
      y, x = elf
      desired_moves = considerations.map { |d| check_direction(elf, d) }.compact

      desired_move =
        case desired_moves.count
        when 4
          nil
        else
          desired_moves.first
        end

      p [:desired, desired_move, elf] if $dbg
      if not desired_move.nil?
        pos = move(elf, desired_move)
        p [:considered_move, pos, elf] if $dbg
        memo[pos] ||= []
        memo[pos] << elf
      end

      memo
    end
  end

  def move(elf, d)
    y, x = elf

    case d
    when :N
      [y - 1, x]
    when :S
      [y + 1, x]
    when :W
      [y, x - 1]
    when :E
      [y, x + 1]
    else
      raise ":X"
    end
  end

  def check_direction(elf, direction)
    y, x = elf

    mods =
      case direction
      when :N
        [[-1, 0], [-1, 1], [-1, -1]]
      when :S
        [[1, 0], [1, 1], [1, -1]]
      when :W
        [[-1, -1], [0, -1], [1, -1]]
      when :E
        [[-1, 1], [1, 1], [0, 1]]
      else
        raise ":O"
      end

    r = mods
      .map { |(dy, dx)| [y + dy, x + dx] }
      .tap { |ms| p [:check_points, ms] if $dbg }
      .all? do |c|
        p [:checking, c, input] if $dbg
        not input.has_key?(c)
      end
    p [:check, elf, r] if $dbg
    direction if r
  end

  def dimensions
    min_y, max_y = input.keys.map{_1[0]}.minmax
    min_x, max_x = input.keys.map{_1[1]}.minmax

    [min_y, max_y, min_x, max_x]
  end

  def count_empty
    min_y, max_y, min_x, max_x = dimensions

    p [:dim, [min_y, max_y], [min_x, max_x], input.size] if $dbg

    ((max_x - min_x + 1) * (max_y - min_y + 1)) - input.size
  end

  def out
    min_y, max_y, min_x, max_x = dimensions

    (min_y..max_y).each do |y|
      (min_x..max_x).each do |x|

        if input[[y, x]]
          print input[[y, x]]
        else
          print "."
        end
      end
      print " #{y} \n"
    end
    puts "#{min_x} ... #{max_x}"
  end
end

solution = Solution.new(ARGF.read)

p solution.play(10).count_empty

p solution.stable



