
sum = 0

left = []
right = []

ARGF.each do |line|
  numbers = line.scan(/\b\d+\b/)
  left << numbers[0].to_i
  right << numbers[1].to_i
end

left = left.sort
right = right.sort

x = left.zip(right).map do |l, r|
  diff = (r - l).abs
end.sum

puts left.inspect, right.inspect, x

left_hash = left.to_h { |l| [l, 0] }

right.each do |r|
  if left_hash[r]
    left_hash[r] += 1
  end
end

# Interestingly I first did this and got the correct answer
# my input must have had a unique set of numbers on the left
# puts left_hash.map { |k, v| k * v }.sum

puts left.map { |l| left_hash[l] * l }.sum
