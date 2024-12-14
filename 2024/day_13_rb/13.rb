require "set"
require "matrix"

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

input = File.read(file).split("\n\n").map do |line|
  a, b, prize = line.split("\n")
  matches = /Button A: X\+(\d+), Y\+(\d+)/.match(a)
  ax, ay = matches[1].to_i, matches[2].to_i

  matches = /Button B: X\+(\d+), Y\+(\d+)/.match(b)
  bx, by = matches[1].to_i, matches[2].to_i

  matches = /Prize: X=(\d+), Y=(\d+)/.match(prize)
  px, py = matches[1].to_i, matches[2].to_i

  { ax: ax, ay: ay, bx: bx, by: by, px: px, py: py }
end

COST_A = 3
COST_B = 1

def cost(input, p1 = true)
  ax, ay, bx, by, px, py = input[:ax], input[:ay], input[:bx], input[:by], input[:px], input[:py]
  cost = 0

  unless p1
    px += 10000000000000
    py += 10000000000000
  end

  gcd_x = ax.gcd(bx)
  gcd_y = ay.gcd(by)
  return nil if px % gcd_x != 0 || py % gcd_y != 0

  m1 = Matrix[[ax, bx], [ay, by]]
  m1_inv = m1.inverse
  m2 = Matrix[[px], [py]]
  m3 = m1_inv * m2
  a = m3[0, 0]
  b = m3[1, 0]

  return nil if a.denominator != 1 || b.denominator != 1
  a, b = a.to_i, b.to_i
  return nil if a < 0 || b < 0

  cost_a = a * COST_A
  cost_b = b * COST_B
  cost_a + cost_b
end

total = input.sum do |i|
  cost(i) || 0
end

puts total

total = input.sum do |i|
  cost(i, false) || 0
end

puts total
