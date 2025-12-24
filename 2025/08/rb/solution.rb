require 'set'

class Solution
  attr_reader :input_data, :lines, :connection_limit

  def initialize(input_data, connection_limit: 10)
    @input_data = input_data
    @lines = input_data.chomp.split("\n")
    @connection_limit = connection_limit
  end

  # Standard AoC methods
  def part1()
    junction_boxes = lines.map { |line| Coord.new(line) }
    n = junction_boxes.size

    edges = []
    (0...n).each do |i|
      (i + 1...n).each do |j|
        edges << [junction_boxes[i].distance_sq(junction_boxes[j]), i, j]
      end
    end
    edges.sort_by! { |dist, _, _| dist }

    uf = UnionFind.new(n)

    edges.first(connection_limit).each do |_, i, j|
      uf.union(i, j)
    end

    uf.circuit_sizes.sort.reverse.take(3).reduce(&:*)
  end

  def part2
    junction_boxes = lines.map { |line| Coord.new(line) }
    n = junction_boxes.size

    edges = []
    (0...n).each do |i|
      (i + 1...n).each do |j|
        edges << [junction_boxes[i].distance_sq(junction_boxes[j]), i, j]
      end
    end
    edges.sort_by! { |dist, _, _| dist }

    uf = UnionFind.new(n)
    num_circuits = n
    last_connected_pair = nil

    edges.each do |_, i, j|
      if uf.union(i, j)
        num_circuits -= 1
        last_connected_pair = [i, j]
      end

      break if num_circuits == 1
    end

    i, j = last_connected_pair
    box1 = junction_boxes[i]
    box2 = junction_boxes[j]

    return box1.x * box2.x
  end
end

class Solution
  class Coord
    attr_reader :x, :y, :z

    def initialize(coords)
      @x, @y, @z = coords.strip.split(",").map(&:to_i)
    end

    # Returns squared Euclidean distance (avoids sqrt for sorting)
    def distance_sq(other)
      (x - other.x)**2 + (y - other.y)**2 + (z - other.z)**2
    end
  end

  class UnionFind
    def initialize(n)
      @parent = Array.new(n) { |i| i }
      @size = Array.new(n, 1)
    end

    def find(i)
      @parent[i] == i ? i : (@parent[i] = find(@parent[i]))
    end

    def union(i, j)
      root_i = find(i)
      root_j = find(j)

      return false if root_i == root_j

      if @size[root_i] < @size[root_j]
        @parent[root_i] = root_j
        @size[root_j] += @size[root_i]
      else
        @parent[root_j] = root_i
        @size[root_i] += @size[root_j]
      end
      true
    end

    def circuit_sizes
      sizes = Hash.new(0)

      @parent.each_index do |i|
        root = find(i)
        sizes[root] = @size[root]
      end

      sizes.values
    end
  end
end
