require 'set'
require_relative 'board.rb'

class Solution
  attr_reader :board

  def initialize(input, world_shape)
    a, b = input.chomp.split("\n\n")

    @board = Board.new(a, world_shape)
  end

  def to_s
    "aasdf"

    <<~EOS
      #{board}

    EOS
  end
end

$dbg = false

input = ARGF.read
solution = Solution.new(input, :flat)

puts solution.to_s

solution = Solution.new(input, :cuboid)
