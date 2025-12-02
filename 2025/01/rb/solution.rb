class Solution
  attr_reader :input_data

  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.split("\n")
  end

  # Standard AoC methods
  def part1
    position = 50
    counter = 0

    @lines
      .map { |it| [it[0], it[1..-1].to_i]}
      .inject(position) do |position, (dir, amount)|
        amount %= 100

        position =
          case dir
          when "L"
            position - amount
          when "R"
            position + amount
          end

        position =
          if position >= 100
            position - 100
          elsif position < 0
            position + 100
          else
            position
          end

        stops << position

        counter += 1 if position.zero?
        position
      end

    counter
  end

  def part2
    position = 50
    counter = 0

    @lines
      .map { |it| [it[0], it[1..-1].to_i]}
      .map { |(dir, amount)| dir == "R" ? amount : -amount }
      .inject(position) do |prev, amount|
        current = prev + amount
        counter += current.abs / 100
        counter += 1 if prev != 0 && current <= 0
        current % 100
      end

    counter
  end
end
