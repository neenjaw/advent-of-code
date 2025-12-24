require 'set'

class Solution
  attr_reader :input_data, :lines

  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.chomp.split("\n")
  end

  def part1
    graph = parse_graph

    count = 0

    queue = ['you']
    while queue.any?
      current = queue.shift

      graph[current].keys.each do |node|
        if node == 'out'
          count += 1
          next
        end

        queue << node
      end
    end

    count
  end

  def part2
    graph = parse_graph
    pp graph

    count = 0

    queue = [['svr', false, false, Set.new]]
    while queue.any?
      shifted_values = queue.shift
      current, fft, dac, visited = shifted_values
      visited << current

      pp shifted_values

      graph[current].keys.each do |node|
        if node == 'out' && fft && dac
          count += 1
          next
        end

        next if visited.include?(node)

        queue << [node, fft || node == 'fft', dac || node == 'dac', visited.dup]
      end
    end

    count
  end

  def part2_dfs
    graph = parse_graph
    dfs(graph, 'svr', false, false, Hash.new())
  end

  def dfs(graph, node, fft, dac, memo)
    state = [node, fft, dac]
    return memo[state] if memo.key?(state)
    return (fft && dac) ? 1 : 0 if node == 'out'

    current_fft = fft || (node == 'fft')
    current_dac = dac || (node == 'dac')

    memo[state] = graph[node]
      .keys
      .sum { dfs(graph, it, current_fft, current_dac, memo) }
  end

  def parse_graph
    lines.inject(Hash.new { |hash, key| hash[key] = {} }) do |acc, line|
      node, *connections = line.delete(":").split(" ")
      connections.each { acc[node][it] = true}
      acc
    end
  end
end
