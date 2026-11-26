# frozen_string_literal: true

require_relative "solution"

input_path = File.expand_path(ARGV.fetch(0, "input.txt"), __dir__)
abort "Input file not found: #{input_path}" unless File.file?(input_path)

input = File.read(input_path)

puts "Part 1: #{Solution.part1(input)}"
puts "Part 2: #{Solution.part2(input)}" if Solution.respond_to?(:part2)
