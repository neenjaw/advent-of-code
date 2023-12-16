require 'set'

def read
  parts = []
  ARGF.read.chomp.split("\n").each do |line|
    part = line.chars
    parts << part
  end
  parts
end

def bfs_traverse(field, start = [[0, 0], :right])
  visited = Set.new
  visited_with_dir = Set.new

  queue = [start]
  while !queue.empty?
    tile, dir = queue.shift
    # puts "Visiting #{tile} #{dir}"
    y, x = tile

    next if x < 0 || y < 0 || y >= field.length || x >= field[y].length || visited_with_dir.include?([tile, dir])

    visited << tile
    visited_with_dir << [tile, dir]

    if field[y][x] == "."
      if dir == :right
        queue << [[y, x + 1], :right]
      elsif dir == :left
        queue << [[y, x - 1], :left]
      elsif dir == :up
        queue << [[y - 1, x], :up]
      elsif dir == :down
        queue << [[y + 1, x], :down]
      else
        raise "Unknown direction: #{dir}"
      end

    elsif field[y][x] == "/"
      if dir == :right
        queue << [[y - 1, x], :up]
      elsif dir == :left
        queue << [[y + 1, x], :down]
      elsif dir == :up
        queue << [[y, x + 1], :right]
      elsif dir == :down
        queue << [[y, x - 1], :left]
      end

    elsif field[y][x] == "\\"
      if dir == :right
        queue << [[y + 1, x], :down]
      elsif dir == :left
        queue << [[y - 1, x], :up]
      elsif dir == :up
        queue << [[y, x - 1], :left]
      elsif dir == :down
        queue << [[y, x + 1], :right]
      end

    elsif field[y][x] == "-"
      if dir == :right
        queue << [[y, x + 1], :right]
      elsif dir == :left
        queue << [[y, x - 1], :left]
      elsif dir == :up || dir == :down
        queue << [[y, x - 1], :left]
        queue << [[y, x + 1], :right]
      end

    elsif field[y][x] == "|"
      if dir == :up
        queue << [[y - 1, x], :up]
      elsif dir == :down
        queue << [[y + 1, x], :down]
      elsif dir == :left || dir == :right
        queue << [[y - 1, x], :up]
        queue << [[y + 1, x], :down]
      end

    else
      raise "Unknown tile: #{field[y][x]}"
    end

  end

  visited
end

def print(field, visited)
  puts (field.map.with_index do |row, y|
    row.map.with_index do |tile, x|
      if visited.include?([y, x])
        "X"
      else
        tile
      end
    end.join
  end.join("\n"))
end

def multi_bfs(field)
  starting_points = [
    0.upto(field.length - 1).map { |y| [[y, 0], :right] },
    0.upto(field.length - 1).map { |y| [[y, field[y].length - 1], :left] },
    0.upto(field.first.length - 1).map { |x| [[0, x], :down] },
    0.upto(field.last.length - 1).map { |x| [[field.length - 1, x], :up] },
  ].flatten(1)

  starting_points.map { |start| bfs_traverse(field, start) }.map(&:size).max
end

grid = read

visited = bfs_traverse(grid)

pp visited.size

max_visited = multi_bfs(grid)

pp max_visited
