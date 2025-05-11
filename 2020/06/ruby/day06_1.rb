groups = []

groups << ARGF.inject({}) do |group, line|
  line = line.chomp
  if line.empty?
    groups << group
    next {}
  end

  line.chars { |c| group[c] = true }
  group
end

puts groups.sum(&:count)
