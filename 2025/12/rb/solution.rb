require 'set'

class Solution
  attr_reader :input_data

  def initialize(input_data)
    @input_data = input_data.chomp
  end

  def part1
    areas = input_data
      .split("\n\n")
      .drop(6)
      .first
      .split("\n")
      .map { process_area(it) }

    areas.count do |area|
      required_area = area.requirements.values.sum * 9
      area.to_i >= required_area
    end
  end

  def process(*shape_inputs)
    shape_inputs.map do |shape_input|
      first, *rest = shape_input.split("\n")
      index = first.chars.first.to_i
      coord_pairs = rest
        .flat_map.with_index do |line, y|
          line.chars.map.with_index do |char, x|
            [[y, x], char] if char == '#'
          end
        end
        .compact

      Shape.new(index, coord_pairs)
    end
  end

  def process_area(area_input)
    dimension_input, *requirement_inputs = area_input.delete(":").split(" ")
    y, x = dimension_input.split("x").map(&:to_i)
    requirements = requirement_inputs.map.with_index { |qty, idx| [idx, qty.to_i]}.to_h

    Area.new(y, x, requirements)
  end

  def part2
    :none
  end

  class Shape
    attr_reader :coords, :index

    def initialize(index, coord_pairs)
      @index, @coords = index, coord_pairs.to_h
    end
  end

  class Area
    attr_reader :h, :w, :requirements

    def initialize(h, w, requirements)
      @h, @w, @requirements = h, w, requirements
    end

    def to_i
      h * w
    end
  end
end
