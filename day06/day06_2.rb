def new_group_pair
  [0, Hash.new(0)]
end

groups = []
last_count, last_group = ARGF.inject(new_group_pair) do |(count, group), line|
  line = line.chomp
  if line.empty?
    groups << group.keep_if { |_, v| v == count }
    next new_group_pair
  end

  line.chars { |c| group[c] += 1 }
  next [count + 1, group]
end

groups << last_group.keep_if { |_, v| v == last_count }

puts groups.sum(&:count)
