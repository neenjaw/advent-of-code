require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    0:
    ###
    ##.
    ##.

    1:
    ###
    ##.
    .##

    2:
    .##
    ###
    ##.

    3:
    ##.
    ###
    ##.

    4:
    ###
    #..
    ###

    5:
    ###
    .#.
    ###

    4x4: 0 0 0 0 2 0
    12x5: 1 0 1 0 2 2
    12x5: 1 0 1 0 3 2
  INPUT

  def read_input
    File.read('input.txt').chomp
  end

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
  end

  def test_part1_solution
    @solver = Solution.new(read_input)

    expected = 599
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    # @solver = Solution.new(read_input)

    expected = :none
    assert_equal expected, @solver.part2
  end
end
