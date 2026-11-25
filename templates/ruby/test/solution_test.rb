# frozen_string_literal: true

require "minitest/autorun"
require_relative "../solution"

class SolutionTest < Minitest::Test
  def test_part1_sample
    input = File.read(File.join(__dir__, "../samples/part1.txt"))

    assert_equal 3, Solution.part1(input)
  end

  def test_part2_sample
    input = File.read(File.join(__dir__, "../samples/part2.txt"))

    assert_equal 5, Solution.part2(input)
  end

  def test_solution_receives_raw_input
    input = "1\n2\n"

    assert_equal 1, Solution.part1(input)
  end
end
