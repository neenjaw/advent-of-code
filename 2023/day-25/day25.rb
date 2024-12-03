require 'set'

# This is not general purpose, but it works for my input.
# I read the input, and then manually removed the edges that
# were bridged the two parts.

# I discovered that the graph was split into two parts by
# rendering it with graphviz, and then looking at the image.

def read
  ARGF.read
end

def parse_graph(input)
  connections = {}
  input.chomp.split("\n").each_with_index do |line, idx|
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

def delete_edge(graph, a, b)
  graph[a].delete(b)
  graph[b].delete(a)
end

input = read

graph = parse_graph(input)

delete_edge(graph, 'bkm', 'ldk')
delete_edge(graph, 'zmq', 'pgh')
delete_edge(graph, 'bvc', 'rsm')

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

puts "a: #{a}"
puts "b: #{b}"
puts "a * b: #{a * b}"

def find_bridges(graph)
  visited = {}
  disc = {}
  low = {}
  parent = {}
  bridges = []

  graph.keys.each do |node|
    visited[node] = false
    disc[node] = Float::INFINITY
    low[node] = Float::INFINITY
    parent[node] = nil
  end

  dfs = lambda do |node, time|
    visited[node] = true
    disc[node] = time
    low[node] = time

    graph[node].each do |neighbor|
      if !visited[neighbor]
        parent[neighbor] = node
        dfs.call(neighbor, time + 1)
        low[node] = [low[node], low[neighbor]].min

        bridges.push([node, neighbor]) if low[neighbor] > disc[node]
      elsif neighbor != parent[node]
        low[node] = [low[node], disc[neighbor]].min
      end
    end
  end

  graph.keys.each do |node|
    dfs.call(node, 0) unless visited[node]
  end

  bridges
end

graph2 = parse_graph(input)

result = find_bridges(graph2)
puts "Bridges in the graph: #{result}"
