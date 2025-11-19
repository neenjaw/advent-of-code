require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    line 1
    line 2
    line 3
  INPUT

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
  end

  def test_part1_solution
    # Replace with the expected answer for your sample input
    expected = 3
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    # Replace with the expected answer for your sample input
    expected = "Not implemented yet"
    assert_equal expected, @solver.part2
  end
end
