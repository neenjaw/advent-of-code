require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
  INPUT

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
    # @solver = Solution.new(File.read('input.txt'))
  end

  def test_part1_solution
    @solver = Solution.new(File.read('input.txt'), connection_limit: 1000)

    expected = 102816
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(File.read('input.txt'), connection_limit: 1000)

    expected = 100011612
    assert_equal expected, @solver.part2
  end
end
