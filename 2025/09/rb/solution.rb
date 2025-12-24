require 'set'

class Solution
  attr_reader :input_data, :lines

  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.chomp.split("\n")
  end

  # Standard AoC methods
  def part1()
    tiles = lines.map { |line| Point2d.parse(line) }
    n = tiles.size

    edges = []
    (0...n).each do |i|
      (i + 1...n).each do |j|
        edges << [tiles[i].area(tiles[j]), i, j]
      end
    end
    edges = edges.sort_by { |area, _, _| area }.reverse

    a, _, _ = edges.first

    a
  end

  def part2
    tiles = lines.map { |line| Point2d.parse(line) }
    shape = find_shape_fast(tiles)
    grid_rectangles = decompose_tile_polygon(shape)
    n = tiles.size

    rectangles = []
    (0...n).each do |i|
      (i + 1...n).each do |j|
        rectangles << [tiles[i].area(tiles[j]), Rectangle.new(tiles[i], tiles[j])]
      end
    end

    rectangles
      .sort_by { |area, _| area }
      .reverse
      .find do |_, query_rectangle|
        fully_covered?(query_rectangle, grid_rectangles)
      end
  end

  def find_shape_fast(points)
    return points if points.length < 3

    # Maps coordinate values to arrays of point objects
    x_map = Hash.new { |h, k| h[k] = [] }
    y_map = Hash.new { |h, k| h[k] = [] }

    points.each do |p|
      x_map[p.x] << p
      y_map[p.y] << p
    end

    unused = Set.new(points)
    current = points.min_by { |p| [p.y, p.x] }

    unused.delete(current)
    path = [current]

    while unused.any?
      candidates = (x_map[current.x] + y_map[current.y]).select { |p| unused.include?(p) }

      next_point = candidates.min_by do |p|
        (p.x - current.x).abs + (p.y - current.y).abs
      end

      path << next_point
      unused.delete(next_point)
      current = next_point
    end

    path
  end

  def decompose_tile_polygon(points)
    # 1. Get unique Y coordinates of the tiles
    y_coords = points.map { |p| p.y }.uniq.sort
    rectangles = []

    # 2. Extract vertical edges
    edges = []
    points.each_with_index do |p1, i|
      p2 = points[(i + 1) % points.length]
      if p1.x == p2.x
        y_min, y_max = [p1.y, p2.y].sort
        edges << { x: p1.x, y_min: y_min, y_max: y_max }
      end
    end

    # 3. Create horizontal strips (slabs)
    y_coords.each_cons(2) do |y_low, y_high|
      # We check the "body" of the slab by looking at the midpoint between Y levels
      mid_y = (y_low + y_high) / 2.0
      active_edges = edges.select { |e| e[:y_min] < mid_y && e[:y_max] > mid_y }
      sorted_x = active_edges.map { |e| e[:x] }.sort

      sorted_x.each_slice(2) do |x_start, x_end|
        next if x_start.nil? || x_end.nil?

        # Sort X to ensure we have min and max
        x1, x2 = [x_start, x_end].sort

        rectangles << {
          x_min: x1,
          y_min: y_low,
          x_max: x2,
          y_max: y_high
        }
      end
    end

    # 4. Vertical Merging
    # If two rectangles share the same X-range and one's max Y is the other's min Y, merge them.
    merged = []
    # Sort primarily by X-range, then by Y position
    rectangles.sort_by! { |r| [r[:x_min], r[:x_max], r[:y_min]] }

    rectangles.each do |r|
      last = merged.last
      if last && last[:x_min] == r[:x_min] && last[:x_max] == r[:x_max] && last[:y_max] == r[:y_min]
        # Extend the previous rectangle's height to the new max
        last[:y_max] = r[:y_max]
      else
        merged << r
      end
    end

    # 5. Format output as opposite corners [[x1, y1], [x2, y2]]
    merged.map do |r|
      Rectangle.new(Point2d.new(r[:x_min], r[:y_min]), Point2d.new(r[:x_max], r[:y_max]))
    end
  end

  def fully_covered?(query_rect, source_rects)
    clipped = source_rects.map { |r| r.clip_to(query_rect) }.compact

    # For tiles, our boundaries are the start and end of each rectangle
    # We add x+1 because a tile at index 'x' ends at the boundary of 'x+1'
    x_breaks = clipped.flat_map { |r| [r.x1, r.x2 + 1] }
    x_breaks << query_rect.x1 << query_rect.x2 + 1
    x_coords = x_breaks.uniq.sort.select { |x| x >= query_rect.x1 && x <= query_rect.x2 + 1 }

    (0...x_coords.length - 1).each do |i|
      start_x = x_coords[i]
      end_x   = x_coords[i+1] - 1 # The last tile index in this strip

      # Find all rectangles that cover this entire horizontal tile strip
      y_intervals = clipped.select { |r| r.x1 <= start_x && r.x2 >= end_x }
                          .map { |r| [r.y1, r.y2] }
                          .sort_by(&:first)

      return false unless tiles_covered?(y_intervals, query_rect.y1, query_rect.y2)
    end

    true
  end

  def tiles_covered?(intervals, target_min, target_max)
    # current_needed tracks the next tile index we need to account for
    current_needed = target_min

    intervals.each do |y1, y2|
      # If this rectangle starts after the tile we need, there's a gap
      return false if y1 > current_needed

      # Update the needed tile to be one past the end of this rectangle
      current_needed = [current_needed, y2 + 1].max
      break if current_needed > target_max
    end

    current_needed > target_max
  end
end

class Solution
  class Point2d
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def self.parse(coords)
      self.new(*coords.strip.split(",").map(&:to_i))
    end

    def area(other)
      ((x - other.x).abs + 1) * ((y - other.y).abs + 1)
    end
  end

  class Rectangle
    attr_reader :x1, :y1, :x2, :y2

    def initialize(p1, p2)
      @x1, @x2 = [p1.x, p2.x].min, [p1.x, p2.x].max
      @y1, @y2 = [p1.y, p2.y].min, [p1.y, p2.y].max
    end

    def self.from_coords(x1, y1, x2, y2)
      self.new(Point2d.new(x1, y1), Point2d.new(x2, y2))
    end

    def x_range; (x1..x2); end
    def y_range; (y1..y2); end

    def clip_to(outer)
      new_x1 = [x1, outer.x1].max
      new_y1 = [y1, outer.y1].max
      new_x2 = [x2, outer.x2].min
      new_y2 = [y2, outer.y2].min

      return nil if new_x1 > new_x2 || new_y1 > new_y2
      Rectangle.new(Point2d.new(new_x1, new_y1), Point2d.new(new_x2, new_y2))
    end
  end
end
