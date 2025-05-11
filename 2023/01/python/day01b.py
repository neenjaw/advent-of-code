import re

class Day01b:
  WORD_TO_DIGIT = {
    'one': '1', 'two': '2', 'three': '3', 'four': '4',
    'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9'
  }

  def calculate_sum(self, lines):
    total = 0

    for line in lines:
      digits = list(map(int, self.words_to_digits(line)))
      first_digit = digits[0]
      last_digit = digits[-1]
      two_digit_number = (first_digit * 10) + last_digit
      total += two_digit_number

    return total

  def words_to_digits(self, input):
    matches = re.findall(r'(?=(one|two|three|four|five|six|seven|eight|nine|\d))', input)
    return ''.join(self.WORD_TO_DIGIT.get(match, match) for match in matches)


if __name__ == "__main__":
  import sys
  day01b = Day01b()
  print(day01b.calculate_sum(sys.stdin))
