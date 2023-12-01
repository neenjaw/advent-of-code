
sum = 0

ARGF.each do |line|
  digits = line.scan(/\d/)
  first_digit = digits.first.to_i
  last_digit = digits.last.to_i
  two_digit_number = (first_digit * 10) + last_digit
  sum += two_digit_number
end

puts sum
