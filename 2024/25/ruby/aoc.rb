require "set"
require 'pry'
require 'matrix'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

puts "file: #{file}"

keys, locks = File.read(file).split("\n\n").map do |section|
  lines = section.split("\n")

  input = lines.each_with_index.map do |line, y|
    line.chars.each_with_index.map do |char, x|
      [[y, x], char] if char == "#"
    end
  end
  .flatten(1)
  .compact
  .to_h

  {type: lines[0] == "#####" ? :lock : :key, input: input, input_set: input.keys.to_set}
end
.partition { |section| section[:type] == :key }

puts "keys: #{keys.count}"
puts "locks: #{locks.count}"

TOTAL = 5 * 7

def print_grid(grid)
  (0...7).each do |y|
    (0...5).each do |x|
      print grid[[y, x]] || "."
    end
    puts
  end
end

ans = keys.each_with_index.sum do |key, i|
  locks.each_with_index.count do |lock, j|
    !key[:input_set].intersect?(lock[:input_set])
  end
end

puts "ans: #{ans}"
