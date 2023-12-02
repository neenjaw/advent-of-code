# frozen_string_literal: true

class Day02a
  def run(input, limits)
    bags = parse_input(input)
    count_valid_bags(bags, limits)
  end

  private

  def parse_input(input)
    input.split("\n").map do |line|
      parts = line.split(/: |; /)
      parts.shift

      parts.reduce({}) do |acc, part|
        part.split(', ').reduce(acc) do |acc, subpart|
          count, color = subpart.split
          count = count.to_i

          acc[color] = [acc[color] || 0, count].max
          acc
        end
      end
    end
  end

  def count_valid_bags(bags, limits)
    bags.each_with_index.map do |game, index|
      under_limit = limits.keys.all? do |color|
        game[color] <= limits[color]
      end

      under_limit ? (index + 1) : 0
    end.sum
  end
end
