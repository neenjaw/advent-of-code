require 'graphviz'

def render_graphviz(string)
  graph = GraphViz.new(:G, type: :digraph, use: :neato)

  lines = string.split("\n")
  lines.each do |line|
    next if line.empty?

    nodes = line.split(':')
    source = nodes[0].strip
    targets = nodes[1].strip.split(' ')

    targets.each do |target|
      graph.add_edges(source, target)
    end
  end

  graph.output(png: 'graph.png')
end

render_graphviz(ARGF.read)
