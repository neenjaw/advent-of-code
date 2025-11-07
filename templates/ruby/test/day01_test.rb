require "minitest/autorun"
require "minitest/pride"

# The Rakefile loads Zeitwerk, which makes Day01 available
# require_relative "../src/day01" # No longer needed thanks to Zeitwerk!

class Day01Test < Minitest::Test
  def setup
    # Sample input data for testing
    @input = "line 1\nline 2\nline 3"
    @solver = Day01.new(@input)
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

  def test_helper_autoload
    # Test that the helper is autoloaded and works
    assert_equal "TSET", Helper.reverse_and_upcase("test")
  end
end
