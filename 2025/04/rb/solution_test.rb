require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@.
  INPUT

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
    # @solver = Solution.new(File.read('input.txt').chomp)
  end

  def test_part1_solution
    @solver = Solution.new(File.read('input.txt').chomp)

    expected = 1540
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(File.read('input.txt').chomp)

    expected = 8972
    assert_equal expected, @solver.part2
  end
end
