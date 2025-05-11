ALPHABET = 'abcdefghijklmnopqrstuvwxyz'.chars.to_a.freeze

groups =
  ARGF
  .read
  .split("\n\n")
  .map { |group| group.split("\n").map { |word| word.chars.to_a } }
  .sum { |group| ALPHABET.intersection(*group).count }

puts groups.inspect
