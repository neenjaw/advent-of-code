require "set"
require 'pry'
require 'matrix'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

a, b = File.read(file).split("\n\n")

$variables = a.split("\n").map do |line|
  matches = line.match(/(\w+): (\d+)/)
  [matches[1], matches[2].to_i]
end.to_h

# puts "variables: #{variables.inspect}"

$or_proc = ->(a, b) { a | b }
$and_proc = ->(a, b) { a & b }
$xor_proc = ->(a, b) { a ^ b }

$equations = b.split("\n").map do |line|
  matches = line.match(/(\w+) (\w+) (\w+) -> (\w+)/)

  proc = case matches[2]
    when "AND"
      $and_proc
    when "OR"
      $or_proc
    when "XOR"
      $xor_proc
    end

  { a: matches[1], b: matches[3], op: matches[2], inputs: Set.new([matches[1], matches[3]]), output: matches[4], proc: proc }
end

gz_text = []
$equations.each_with_index do |eq, i|
  inputs = eq[:inputs].to_a
  inputs.each do |input|
    gz_text << "  #{input} -> #{eq[:op]}#{i};"
  end
  gz_text << "  #{eq[:op]}#{i} -> #{eq[:output]};"
end

puts "digraph G {"

puts gz_text.uniq
puts "}"
