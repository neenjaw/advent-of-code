require 'set'

class Solution
  attr_reader :input

  def initialize(input)
    @input = input.chomp
      .split("\n")
      .map(&:to_i)
  end

  def build_cycle(multiplier)
    nodes = input
      .map do |n|
        {prev: nil, value: n * multiplier, next: nil}
      end

    nodes.map
      .with_index do |node, i|
        node[:prev] = nodes[i - 1]
        node[:next] = nodes[(i + 1) % nodes.size]

        [i, node]
      end
      .to_h
  end

  def cycle_to_a(cycle)
    starting_node = cycle[0]
    node = cycle[0]
    values = []
    loop do
      values << node[:value]

      node = node[:next]
      break if node == starting_node
    end

    values
  end

  def run(multiplier = 1, runs = 1)
    cycle = build_cycle(multiplier)

    runs.times {
      print "."
      (0...cycle.size).each do |i|
        origin = cycle[i]
        move = origin[:value]

        next if move.zero?

        direction = move >= 0 ? :forward : :back
        remaining = move.abs

        target = origin

        origin[:prev][:next] = origin[:next]
        origin[:next][:prev] = origin[:prev]

        remaining %= cycle.size - 1

        while remaining > 0
          remaining -= 1
          case direction
          when :forward
            target = target[:next]
          when :back
            target = target[:prev]
          end
        end


        case direction
        when :forward
          origin[:next] = target[:next]
          target[:next] = origin
          origin[:prev] = target
          origin[:next][:prev] = origin
        when :back
          origin[:prev] = target[:prev]
          target[:prev] = origin
          origin[:next] = target
          origin[:prev][:next] = origin
        end
      end
    }

    result =cycle_to_a(cycle)
    zero_i = result.find_index(0)
    [1000, 2000, 3000].map{ |n| result[(n + zero_i) % result.size] }.sum
  end

  def other_approach
    data = @input.each_with_index.map { |n, i| [n , i] }
    data = @input.each_with_index.map { |n, i| [n * 811589153, i] }

    10.times do
      data.size.times do |n|
        i = data.find_index {_2 == n}
        v = data.delete_at(i)
        data.insert((i + v[0]) % data.size, v)
      end
    end

    i = data.find_index { _1[0] == 0 }
    x = data[(i + 1000) % data.size][0]
    y = data[(i + 2000) % data.size][0]
    z = data[(i + 3000) % data.size][0]
    p i, x, y, z, x+y+z

  end
end

solution = Solution.new(ARGF.read)
p solution.run
p solution.run(811589153, 10)

p "--------------"

p.other_approach