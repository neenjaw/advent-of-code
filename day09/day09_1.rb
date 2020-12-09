require 'benchmark'
require 'set'

window_min_size = 25
numbers = []
first_not_found = nil

ARGF.readlines.map { |line| line.chomp.to_i }.each.with_index do |number, idx|
  numbers << number
  next if idx < window_min_size

  window = numbers[idx - window_min_size..idx - 1]

  first_not_found = number if first_not_found.nil? && !window.combination(2).map { |(a, b)| a + b }.include?(number)

  break unless first_not_found.nil?
end

a = 0
b = 1
sum = numbers[a] + numbers[b]

while sum != first_not_found
  if sum < first_not_found
    b += 1
    sum += numbers[b]
  elsif sum > first_not_found
    sum -= numbers[a]
    a += 1
  end
end

min, max = numbers[a..b].minmax

puts "Not found: #{first_not_found}"
puts "Min: #{min}"
puts "Max: #{max}"
puts "Min + Max: #{min + max}"
