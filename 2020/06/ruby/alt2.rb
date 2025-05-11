ALPHABET = 'abcdefghijklmnopqrstuvwxyz'.chars.to_a.freeze

def replace_last_group_with_sum(groups)
  group = groups.pop
  groups << ALPHABET.intersection(*group).count
end

groups =
  ARGF.each_with_object([[]]) do |line, groups|
    line = line.chomp
    next groups.last << line.chars.to_a unless line.empty?

    unless groups.last.empty?
      replace_last_group_with_sum(groups)
      groups << []
    end
  end
replace_last_group_with_sum(groups)

puts groups.sum
