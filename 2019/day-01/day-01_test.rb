require 'minitest/autorun'
require 'minitest/pride'
require_relative 'day-01'

class Day01Test < Minitest::Test
  def test_total_fuel_required
    assert_equal 2, total_fuel_required([12])
    assert_equal 2, total_fuel_required([14])
    assert_equal 654, total_fuel_required([1969])
    assert_equal 33_583, total_fuel_required([100_756])
    assert_equal 34_237, total_fuel_required([1969, 100_756])
  end
end
