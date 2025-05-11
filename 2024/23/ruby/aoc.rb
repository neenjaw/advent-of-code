require "set"
require 'pry'
require 'matrix'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

puts "file: #{file}"

$edges = File.readlines(file)
  .map(&:chomp)
  .map { _1.split("-") }
  .inject(Hash.new { |h, k| h[k] = Set.new }) do |hash, (from, to)|
    hash[from] << to
    hash[to] << from
    hash
  end

$nodes = $edges.flatten.uniq

puts $edges.inspect
puts $nodes.inspect

# THIS IS TOO SLOW FOR PART 2

p1 = $edges.map do |k, v|
  puts "k: #{k}, v: #{v.inspect}"
  v << k
  v
end.uniq

puts "p1: #{p1.inspect}"

def find_clusters()
  nodes = $nodes.dup
  clusters = []

  while nodes.any?
    start = nodes.shift

    visited = Set.new
    queue = [[start]]
    while queue.any?
      path = queue.shift
      node = path.last
      visited << node

      $edges[node].each do |neighbor|
        if neighbor == start && path.size > 2
          clusters << path.to_set
          break
        end

        next if visited.include?(neighbor)

        queue << path + [neighbor]
      end
    end
  end

  clusters.uniq
end

p1 = find_clusters().count { |s| s.any? { |n| n.start_with?("t") } }
puts "p1: #{p1.inspect}"
