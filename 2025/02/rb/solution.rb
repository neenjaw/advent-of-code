require 'set'

class Solution
  attr_reader :input_data
  attr_accessor :debug

  def initialize(input_data)
    @input_data = input_data
    @ranges = input_data.split(/[,\n]/).reject(&:empty?)
    @debug = false
  end

  # Standard AoC methods
  def part1
    @ranges
      .map do
        it.split("-")
          .map(&:to_i)
      end
      .map { count_patterns(*it) }.tap { pp it.flatten if debug }.sum { it.sum }
  end

  def part2
    @ranges
      .map do
        it.split("-")
          .map(&:to_i)
      end
      .map { count_patterns_2(*it) }
      .reduce(Set.new, &:|)
      .sum
  end

  private

  def count_patterns(a, b)
    pp [a, b] if debug

    invalids = []
    left, right = split_numeric(a)
    pp [left, right] if debug
    current = left
    chk = combine_numeric(current, 2)
    until chk > b
      if chk >= a && chk <= b
        invalids << chk
      end

      current += 1
      chk = combine_numeric(current, 2)
    end

    invalids
  end

  def count_patterns_2(a, b)
    invalids = Set.new

    (a..b).each do |i|
      id = i.to_s
      id_len = id.length

      (1..(id_len / 2)).each do |pattern_len|
        div, rem = id_len.divmod(pattern_len)
        next unless rem.zero?

        pattern = id.slice(0, pattern_len)
        if pattern * div == id
          invalids << i
          break
        end
      end
    end

    invalids
  end

  def split_numeric(a)
    str = a.to_s
    second_half_start = str.length / 2
    [str.slice(0, second_half_start).to_i, str.slice(second_half_start..-1).to_i]
  end

  def combine_numeric(a, n)
    (a.to_s * n).to_i
  end
end
