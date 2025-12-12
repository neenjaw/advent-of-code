require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    3-5
    10-14
    16-20
    12-18

    1
    5
    8
    11
    17
    32
  INPUT

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
    # @solver = Solution.new(File.read('input.txt').chomp)
  end

  def test_part1_solution
    @solver = Solution.new(File.read('input.txt').chomp)

    expected = 733
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(File.read('input.txt').chomp)

    expected = 345821388687084
    assert_equal expected, @solver.part2
  end

  def test_new_range_set
    rs = Solution::NumericRangeSet.new([1..2])

    expected = [1..2]
    assert_equal expected, rs.to_a
  end

  def test_new_range_set_flattens
    rs = Solution::NumericRangeSet.new([1..2, 3..4, 4..5])

    expected = [1..5]
    assert_equal expected, rs.to_a
  end

  def test_new_should_flatten_reversed
    rs = Solution::NumericRangeSet.new([4..5, 3..4, 1..2])

    expected = [1..5]
    assert_equal expected, rs.to_a
  end

  def test_include?
    rs = Solution::NumericRangeSet.new([4..5, 3..4, 1..2])

    refute rs.include?(0)
    assert rs.include?(1)
    assert rs.include?(2)
    assert rs.include?(3)
    assert rs.include?(4)
    assert rs.include?(5)
    refute rs.include?(6)
  end
end
