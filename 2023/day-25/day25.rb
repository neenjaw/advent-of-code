require 'set'

# This is not general purpose, but it works for my input.
# I read the input, and then manually removed the edges that
# were bridged the two parts.

# I discovered that the graph was split into two parts by
# rendering it with graphviz, and then looking at the image.

def read
  connections = {}
  ARGF.read.chomp.split("\n").each_with_index do |line, idx|
    line =~ /(\w+): (.*)/
    a, bs = $1, $2.split(' ')

    bs.each do |b|
      connections[a] ||= Set.new
      connections[a] << b
      connections[b] ||= Set.new
      connections[b] << a
    end
  end
  connections
end

graph = read

pp graph

graph['bkm'].delete('ldk')
graph['ldk'].delete('bkm')
graph['zmq'].delete('pgh')
graph['pgh'].delete('zmq')
graph['bvc'].delete('rsm')
graph['rsm'].delete('bvc')

def count_nodes_visited(graph, start)
  visited = Set.new

  queue = [start]
  while !queue.empty?
    node = queue.shift
    next if visited.include?(node)

    visited << node
    neighbors = graph[node] || Set.new

    neighbors.each do |neighbor|
      queue << neighbor
    end
  end

  visited.size
end

a = count_nodes_visited(graph, 'bkm')
b = count_nodes_visited(graph, 'rsm')

pp a, b, a * b
