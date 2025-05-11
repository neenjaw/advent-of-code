# Advent of Code 2023, Day 3
#
# Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
# Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
# Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
# Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
# Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
# Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

require 'set'

results = ARGF.each_line.with_index.map do |line, index|
  _, numbers = line.chomp.split(': ')
  winning, current = numbers.split(' | ')
  winning_numbers = winning.split(' ').map(&:to_i)
  current_numbers = current.split(' ').map(&:to_i)

  winning_current_numbers = Set.new(winning_numbers).intersection(Set.new(current_numbers))

  points =
    if winning_current_numbers.length > 0
      1 << winning_current_numbers.length - 1
    else
      0
    end

  copies_won =
    if winning_current_numbers.length > 0
      (index + 1)..(index+winning_current_numbers.length)
    else
      []
    end


  { index: index + 1, points: points, copies_won: copies_won }
end

pp results.map { |card| card[:points] }.sum

def follow_card(results, card)
  count = 1

  card[:copies_won].each do |copy|
    count += follow_card(results, results[copy])
  end

  count
end

recursive_count = results.inject(0) do |acc, card|
  count = follow_card(results, card)
  acc + count
end

pp recursive_count
