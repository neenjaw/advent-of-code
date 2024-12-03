elves = ARGF.read
  .chomp
  .split(/\n\n/)
  .map { |content| content.split(/\n/).map(&:to_i).sum }

p elves.max

p elves.max(3).sum