require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
  INPUT

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
    # @solver = Solution.new(File.read('input.txt'))
  end

  def test_part1_solution
    @solver = Solution.new(File.read('input.txt'))

    expected = 4777816465
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(File.read('input.txt'))

    expected = 1410501884
    assert_equal expected, @solver.part2.first
  end
end
