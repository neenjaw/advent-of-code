# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require_relative 'day02a'
require_relative 'day02b'

class Day02Test < Minitest::Test
  BASIC_LIMIT = { 'red' => 12, 'green' => 13, 'blue' => 14 }

  def test_example_one
    data = <<~DATA
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    DATA
    assert_equal 8, Day02a.new.run(data, BASIC_LIMIT)
  end

  def test_input_one
    data = File.read('./input.txt')
    assert_equal 2061, Day02a.new.run(data, BASIC_LIMIT)
  end

  def test_example_two
    data = <<~DATA
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    DATA
    assert_equal 2286, Day02b.new.run(data)
  end

  def test_input_two
    data = File.read('./input.txt')
    assert_equal 72_596, Day02b.new.run(data)
  end
end
