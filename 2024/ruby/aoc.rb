require "set"
require 'pry'
require 'matrix'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

puts "file: #{file}"

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

  { a: matches[1], b: matches[3], inputs: Set.new([matches[1], matches[3]]), output: matches[4], proc: proc }
end

# puts "equations: #{equations.inspect}"

known_variables = $variables.keys.to_set
unconsidered = $equations.dup
while unconsidered.any?
  eq_idx = unconsidered.index { |eq| eq[:inputs].subset?(known_variables) }
  raise "No equation found" if !eq_idx
  eq = unconsidered.delete_at(eq_idx)

  a, b = $variables[eq[:a]], $variables[eq[:b]]

  result = eq[:proc].call(a, b)
  $variables[eq[:output]] = result
  known_variables << eq[:output]
end

i = 0
str = ""
loop do
  z_key = "z%02d" % i
  z_value = $variables[z_key]
  break if !z_value
  str = z_value.to_s(2) + str
  i += 1
end

$max_i = str.size - 1

puts "Part 1: #{str.to_i(2)}"

def test_bit(i)
  test_vars = $variables.dup.select { |k, v| k.start_with?("x") || k.start_with?("y") }.to_h
  test_result = (0..$max_i).reduce('') { |acc, j| acc + (j == i ? '1' : '0') }.to_i(2)
  (0..$max_i).each { |j| test_vars["x%02d" % j] = i == j ? 1 : 0 }
  (0..$max_i).each { |j| test_vars["y%02d" % j] = 0 }

  known_variables = test_vars.keys.to_set
  unconsidered = $equations.dup
  while unconsidered.any?
    eq_idx = unconsidered.index { |eq| eq[:inputs].subset?(known_variables) }
    raise "No equation found" if !eq_idx
    eq = unconsidered.delete_at(eq_idx)

    a, b = test_vars[eq[:a]], test_vars[eq[:b]]

    result = eq[:proc].call(a, b)
    test_vars[eq[:output]] = result
    known_variables << eq[:output]
  end

  test_i = 0
  str = ""
  loop do
    z_key = "z%02d" % test_i
    z_value = test_vars[z_key]
    break if !z_value
    str = z_value.to_s(2) + str
    test_i += 1
  end

  x = (0..$max_i).reduce('') { |acc, j| (j == i ? '1' : '0') + acc }
  z = str
  diffs = x.chars.reverse.zip(z.chars.reverse).each_with_index.select { |(x, z), j| x != z }
  wrong_bits = diffs.map { |(x, z), j| "z%02d" % j }.to_set
  other_affected_wires = $equations.select { |eq| wrong_bits.include?(eq[:output]) }.map { |eq| eq[:inputs].to_a }.flatten.to_set

  [
    x,
    z,
    diffs,
    wrong_bits,
    other_affected_wires
  ]
end

(0..$max_i).each do |i|
  x, z, diffs, wrong_bits, o = test_bit(i)
  puts "i: #{"%02d" % i}, x: #{x}, z: #{z}, diffs: #{wrong_bits.inspect},\n   other_affected_wires: #{o.inspect}" if wrong_bits.any?
end

puts [
  "shj","z07",
  "pfn","z23",
  "kcd",'z27',
  "wkb","tpk",
  ].sort.join(",")
