# frozen_string_literal: true

class Day02b
  def run(input)
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
    end.map do |game|
      game.values.inject(:*)
    end.sum
  end
end
