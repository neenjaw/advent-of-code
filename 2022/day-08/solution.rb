require 'set'

class Trees
  def initialize(content)
    @grid = content
  end

  def count_all
    visible_trees = Set.new

    left = @grid
    count_side(left, visible_trees, :left)

    right = @grid.map(&:reverse)
    count_side(right, visible_trees, :right)

    top = @grid.transpose
    count_side(top, visible_trees, :top)

    bottom = @grid.transpose.map(&:reverse)
    count_side(bottom, visible_trees, :bottom)

    visible_trees.size
  end

  def count_side(grid, visible_tree_set, direction)
    grid.each_with_index do |row, y|
      row.each_with_index.reduce(-1) do |max, (tree, x)|
        height = tree.to_i
        if height > max
          visible_tree_set.add(translate_direction_coords(direction, y, x))
          next height
        end

        max
      end
    end
  end

  def translate_direction_coords(direction, y, x)
    case direction
    when :left
      [x, y]
    when :right
      [@grid[0].size - 1 - x, y]
    when :top
      [y, x]
    when :bottom
      [y, @grid.size - 1 - x]
    end
  end

  def scenic_score
    (0...@grid.size).map do |y|
      (0...@grid[0].size).map do |x|
        [[0,1],[0,-1],[1, 0],[-1,0]].map do |(dx, dy)|
          count = 0
          height = @grid[y][x].to_i
          cx, cy = x, y
          loop do
            cx, cy = cx + dx, cy + dy
            break if not (0...@grid[0].size).include?(cx) or not (0...@grid.size).include?(cy)

            count += 1

            if @grid[cy][cx].to_i >= height
              break
            end
          end

          count
        end.reduce(&:*)
      end
    end.flatten.max
  end
end

content = ARGF.read.chomp.split(/\n/).map(&:chars)
trees = Trees.new(content)
pp trees.count_all
pp trees.scenic_score

