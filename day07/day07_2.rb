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

# Bag class facilitates a DFS traversal looking for the total
# weight of all paths from root to the leaves
class Bag
  attr_reader :bags

  def initialize(bags)
    @bags = bags
  end

  def traverse(node)
    bags[node].sum { |next_node, m| m + m * traverse(next_node) }
  end
end

puts "solution 2: #{Bag.new(bags).traverse(TARGET)}"
