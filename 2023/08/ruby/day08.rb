# RL

# AAA = (BBB, CCC)
# BBB = (DDD, EEE)
# CCC = (ZZZ, GGG)
# DDD = (DDD, DDD)
# EEE = (EEE, EEE)
# GGG = (GGG, GGG)
# ZZZ = (ZZZ, ZZZ)

require 'set'

pattern = ARGF.readline.chomp.chars
graph = Hash.new
ARGF.each_line do |line|
  next if line.chomp.empty?

  node, left, right = line.chomp.gsub(/[\(\)=,]/, '').split
  graph[node] = [left, right]
end

pp pattern
pp graph

start_point, end_point = ['AAA', 'ZZZ'] if graph['AAA']
start_point, end_point = ['11A', '11Z'] if graph['11A']

point = start_point

steps_taken = 0
pattern.cycle do |p|
  break if point == end_point

  steps_taken += 1
  if p == 'L'
    point = graph[point][0]
  elsif p == 'R'
    point = graph[point][1]
  end
end

pp steps_taken


points = graph.keys.select { |k| k =~ /A$/ }

def find_steps(pattern, graph, point, offset = 0)
  cycle = pattern.cycle

  offset.times { cycle.next }

  steps_taken = 0
  cycle.each do |p|
    steps_taken += 1

    if p == 'L'
      point = graph[point][0]
    elsif p == 'R'
      point = graph[point][1]
    end

    break if point.end_with?('Z')
  end
  [steps_taken, point]
end

x = points
  .map do |point|
    offset, end_point = find_steps(pattern, graph, point)
    cycle_length, _ = find_steps(pattern, graph, end_point, offset)

    offset
  end
  .inject(&:lcm)

pp x
