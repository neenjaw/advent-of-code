# frozen_string_literal: true

class Day02b
  def run(input)
    parse_input(input).map do |game|
      calculate_score(game)
    end.sum
  end

  def parse_input(input)
    input.split("\n").map do |line|
      parts = line.split(/: |; /)
      parts.shift
      parts.reduce({}) do |acc, part|
        part.split(', ').reduce(acc) do |acc, subpart|
          count, color = subpart.split()
          count = count.to_i

          # if the color is in the hash, use the maximum of the current and previous
          acc[color] = [acc[color] || 0, count].max
          acc
        end
      end
    end
  end

  def calculate_score(game)
    game.values.inject(:*)
  end
end
