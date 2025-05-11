# frozen_string_literal: true

class Day01b
  WORD_TO_DIGIT = {
    'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4',
    'five' => '5', 'six' => '6', 'seven' => '7', 'eight' => '8', 'nine' => '9'
  }.freeze

  def calculate_sum(lines)
    sum = 0

    lines.each do |line|
      digits = words_to_digits(line).scan(/\d/)
      first_digit = digits.first.to_i
      last_digit = digits.last.to_i
      two_digit_number = (first_digit * 10) + last_digit
      sum += two_digit_number
    end

    sum
  end

  private

  def words_to_digits(input)
    input.scan(/(?=(one|two|three|four|five|six|seven|eight|nine|\d))/).flatten.map do |match|
      WORD_TO_DIGIT[match] || match
    end.join
  end
end

puts Day01b.new.calculate_sum(ARGF.each)
