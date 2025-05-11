require "set"
require 'pry'
require 'matrix'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

puts "file: #{file}"

numbers = File.readlines(file).map(&:chomp).map(&:to_i)

def mix(a, b)
  a ^ b
end

def prune(a)
  a.to_i % 16777216
end

def process(secret)
  product = secret * 64
  secret = mix(product, secret)
  secret = prune(secret)
  dividend = secret / 32
  secret = mix(dividend, secret)
  secret = prune(secret)
  product = secret * 2048
  secret = mix(product, secret)
  prune(secret)
end

$buyers = Hash.new { |h, k| h[k] = [] }
p1 = []
b = 0
while !numbers.empty?
  n = numbers.shift
  if $buyers[b].empty?
    x = n % 10
    $buyers[b] << [x, nil]
  end
  2000.times do
    new_n = process(n)
    current = new_n % 10
    last = $buyers[b].last.first
    $buyers[b] << [current, last - current]

    n = new_n
  end
  p1 << n
  b += 1
end

puts "Part 1: #{p1.sum}"

$buy_sequences = Hash.new { |h, k| h[k] = {} }

$buyers.each do |k, v|
  puts "Buyer #{k}"
  v.drop(1).each_cons(4) do |((_, a), (_, b), (_, c), (x, d))|
    if !$buy_sequences[k][[a, b, c, d]]
      $buy_sequences[k][[a, b, c, d]] = x
    end
  end
end

x = $buy_sequences.values
  .reduce(Hash.new { |h, k| h[k] = 0 }) do |acc, v|
    v.each do |k, x|
      acc[k] += x
    end
    acc
  end
  .max_by { |k, v| v }

puts x.inspect
