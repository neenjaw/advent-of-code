TARGET = 'shiny gold bag'.freeze
NO_CHILD = 'no other bags'.freeze
bags = {}

# Create an adjacency hash from the rules
ARGF.each do |line|
  from, _, tos = line.chomp[0..-2].partition(' contain ')

  from = from[0..-2]
  bags[from] = {}

  next if tos == NO_CHILD

  tos
    .split(', ')
    .each do |to|
      count, _, dest = to.partition("\s")
      dest = dest.end_with?('s') ? dest[0..-2] : dest
      bags[from][dest] = count.to_i
    end
end

# Perform BFS-ish search of the graph looking for the TARGET (shiny bag)
count = 0
bags.keys.each do |bag|
  next if bag == TARGET

  found = false
  visited = {}
  queue = [bag]

  until found || queue.empty?
    current = queue.pop
    visited[current] = true

    dests = bags[current].keys
    until found || dests.empty?
      dest = dests.pop

      if dest == TARGET
        found = true
        count += 1
        next
      end
      queue.push(dest) unless dest == TARGET || visited[dest]
    end
  end
end

puts "solution 1: #{count}"
