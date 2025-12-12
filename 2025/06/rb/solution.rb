class Solution
  attr_reader :input_data, :equations, :transposed_equations

  def initialize(input_data)
    @input_data = input_data
    @equations = parse_equations
    @transposed_equations = parse_transposed_equations
  end

  # Standard AoC methods
  def part1
    equations.sum(&:apply)
  end

  def part2
    transposed_equations.sum(&:apply)
  end

  private

  def parse_equations
    input_data
      .chomp
      .split("\n")
      .map { it.strip.split(/\s+/) }
      .transpose
      .map(&:reverse)
      .map do |parts|
        op, *args = parts
        Eq.new(op.to_sym, args.map(&:to_i))
      end
  end

  def parse_transposed_equations
    input_data
      .chomp
      .split("\n")
      .map { it.split("") }
      .transpose
      .map { it.join("") }
      .slice_before(/[*+]/)
      .map do |line|
        line.flat_map do |row|
          matches = row.scan(/(\d+)\s*([+*])?/)

          next [] unless matches[0]

          number = matches[0][0]
          symbol = matches[0][1]

          next [number] unless symbol
          next [symbol.to_sym, number] if symbol
        end
      end
      .map do |parts|
        ops, nums = parts.partition { it.is_a?(Symbol) }

        Eq.new(ops.first, nums.map(&:to_i))
      end
  end
end

class Solution
  class Eq
    attr_reader :operator, :args

    def initialize(operator, args)
      @operator = operator.freeze
      @args = args.dup.freeze
    end

    def apply
      args.reduce(&operator)
    end
  end
end
