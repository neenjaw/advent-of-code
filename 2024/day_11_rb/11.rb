require "set"

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

input = File.readlines(file).map(&:chomp).first.split(" ").map(&:to_i)

def part1(input, iters = 25)
  stones = input.dup

  iters.times do
    next_stones = []
    stones.each do |stone|
      if stone == 0
        next_stones << 1
      elsif (digits = stone.digits.reverse).length.even?
        first_half = digits[0...(digits.length / 2)].join.to_i
        second_half = digits[(digits.length / 2)..-1].join.to_i

        puts "stone: #{stone}, first_half: #{first_half}, second_half: #{second_half}" if DEBUG

        next_stones << first_half
        next_stones << second_half
      else
        next_stones << (stone * 2024)
      end
    end
    stones = next_stones
  end

  stones
end

result = part1(input)
puts "Part 1: #{result.count}"


def part2(input, iters = 75)
  stones = input.dup.tally
  iters.times do
    next_stones = Hash.new(0)
    stones.each do |stone, count|
      if stone == 0
        next_stones[1] += count
      elsif (digits = stone.digits.reverse).length.even?
        first_half = digits[0...(digits.length / 2)].join.to_i
        second_half = digits[(digits.length / 2)..-1].join.to_i

        next_stones[first_half] += count
        next_stones[second_half] += count
      else
        next_stones[stone * 2024] += count
      end
    end
    stones = next_stones
  end

  stones
end

result = part2(input)
puts "Part 2: #{result.values.sum}"
