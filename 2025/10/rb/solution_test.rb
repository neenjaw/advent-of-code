require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  INPUT

  def read_input
    File.read('input.txt').chomp
  end

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
  end

  def test_part1_solution
    @solver = Solution.new(read_input)

    expected = 502
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(read_input)

    expected = 21467
    assert_equal expected, @solver.part2
  end
end
