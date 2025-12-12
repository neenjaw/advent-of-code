class Solution
  attr_reader :input_data, :range_sets, :ingredients

  def initialize(input_data)
    @input_data = input_data
    @range_inputs, @ingredient_inputs = input_data.split("\n\n").map { it.split("\n") }
    @range_sets = parse_range_sets
    @ingredients = parse_ingredients
  end

  # Standard AoC methods
  def part1
    ingredients.count { range_sets.include?(it) }
  end

  def part2
    range_sets.to_a.sum { it.size }
  end

  private

  def parse_range_sets
    ranges = @range_inputs
      .map { it.split('-').map(&:to_i) }
      .map { |(a, b)| a..b }

    NumericRangeSet.new(ranges)
  end

  def parse_ingredients
    @ingredient_inputs.map(&:to_i)
  end
end

class Solution
  class NumericRangeSet
    attr_reader :ranges

    def initialize(ranges)
      @ranges = ranges
      flatten
    end

    def include?(item)
      ranges.any? { it.include?(item) }
    end

    def to_a
      ranges.dup
    end

    private

    def flatten
      return if ranges.size <= 1

      sorted_ranges = ranges.sort do |a, b|
        a.first <=> b.first
      end

      new_ranges = [sorted_ranges.first]

      sorted_ranges.each do |range|
        prev_range = new_ranges.pop

        if adjacent?(prev_range, range) || overlap?(prev_range, range)
          new_ranges << (
            [range.first, prev_range.first].min..[range.last, prev_range.last].max
          )
        else
          new_ranges << prev_range
          new_ranges << range
        end
      end

      @ranges = new_ranges
    end

    # a, b must be sorted by range start
    def adjacent?(a, b)
      a.last == b.first - 1 || b.first == a.last + 1
    end

    def overlap?(a, b)
      # 1...5
      #    4...8
      #
      # 1......8
      #    45
      #
      #    4...8
      # 1...5

      (a.last >= b.first && a.last <= b.last) ||
      (a.first >= b.first && a.first <= b.last) ||
      (a.first <= b.first && a.last >= b.last)
    end
  end
end
