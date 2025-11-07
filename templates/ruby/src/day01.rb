# Zeitwerk expects this class name to match the file name (day01.rb -> Day01)
class Day01
  attr_reader :input_data

  def initialize(input_data)
    @input_data = input_data
    # Process the input here, e.g., convert to an array of lines or integers
    @lines = input_data.split("\n")
  end

  # Standard AoC methods
  def part1
    # Your Part 1 logic here
    @lines.size # Example: just return the number of lines
  end

  def part2
    # Your Part 2 logic here
    "Not implemented yet"
  end
end
