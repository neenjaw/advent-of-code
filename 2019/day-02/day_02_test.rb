require 'minitest/autorun'
require 'minitest/pride'
require_relative 'day_02'

class Day02Test < Minitest::Test
  def test_run_intcode_program
    program = [1,0,0,0,99]
    assert_equal 2, run_intcode_program(program)

    program = [2, 3, 0, 3, 99]
    assert_equal 2, run_intcode_program(program)

    program = [2, 4, 4, 5, 99, 0]
    assert_equal 2, run_intcode_program(program)

    program = [1, 1, 1, 4, 99, 5, 6, 0, 99]
    assert_equal 30, run_intcode_program(program)
  end
end
