require "minitest/autorun"
require_relative "solution"

class SolutionTest < Minitest::Test
  # Sample input data for testing (using heredoc)
  SAMPLE_INPUT = <<~INPUT
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out
  INPUT

  SAMPLE_INPUT_2 = <<~INPUT
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out
  INPUT

  def read_input
    File.read('input.txt').chomp
  end

  def setup
    @solver = Solution.new(SAMPLE_INPUT)
  end

  def test_part1_solution
    @solver = Solution.new(read_input)

    expected = 574
    assert_equal expected, @solver.part1
  end

  def test_part2_solution
    @solver = Solution.new(SAMPLE_INPUT_2)
    @solver = Solution.new(read_input)

    expected = 306594217920240
    assert_equal expected, @solver.part2_dfs
  end
end
