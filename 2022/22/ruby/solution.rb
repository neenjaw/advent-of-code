require 'set'
require_relative 'board'
require_relative 'visitor'


class Solution
  attr_reader :board, :instructions

  def initialize(input, world_shape)
    a, b = input.chomp.split("\n\n")

    @board = Board.new(a, world_shape)
    @instructions = b.scan(/(\d+|[LR])/).flatten.map { |i| i =~ /\d+/ ? i.to_i : i }
    @world_shape = world_shape
  end

  def solve
    case @world_shape
    when :flat
      FlatVisitor.new(board).run(instructions)
    when :cuboid
      CuboidVisitor.new(board).run(instructions)
    end
  end

  def to_s
    <<~END_STRING
      #{board}

    END_STRING
  end
end

$dbg = false

input = ARGF.read
solution = Solution.new(input, :flat)

puts solution.to_s

p solution.solve

solution = Solution.new(input, :cuboid)

puts solution.to_s

p solution.solve

# 103027 WAY OFF
# 133028 TOO LOW
# 144212 TOO HIGH

