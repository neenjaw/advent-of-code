require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT =
    "123 328  51 64 \n" +
    " 45 64  387 23 \n" +
    "  6 98  215 314\n" +
    "*   +   *   +  \n"

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
    # @solver = Solution.new(File.read('input.txt'))
  end

  def test_part1_solution
    @solver = Solution.new(File.read('input.txt'))

    expected = 4878670269096
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(File.read('input.txt'))

    expected = 8674740488592
    assert_equal expected, @solver.part2
  end
end
