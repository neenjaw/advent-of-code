require 'set'

# #.##..##.
# ..#.##.#.
# ##......#
# ##......#
# ..#.##.#.
# ..##..##.
# #.#.##.#.

# #...##..#
# #....#..#
# ..##..###
# #####.##.
# #####.##.
# ..##..###
# #....#..#


def read
  mirrors = []
  ARGF.read.chomp.split("\n\n").each do |lines|
    mirror = lines.split("\n").map(&:chars)
    mirrors << mirror
  end
  mirrors
end

def check_reflection_point(mirror, index)
  y1 = index
  y2 = index + 1

  while y1 >= 0 && y2 < mirror.length
    if mirror[y1] != mirror[y2]
      return false
    end
    y1 -= 1
    y2 += 1
  end

  return true
end

def find_reflection_point_index(mirror)
  mirror.each_cons(2).with_index do |(row1, row2), y1|
    if row1 == row2 && check_reflection_point(mirror, y1)
      return y1
    end
  end

  nil
end

def find_reflection_point_index_memo(memo, direction, mirror)
  mirror.each_cons(2).with_index do |(row1, row2), y1|
    if row1 == row2 && !memo.key?([direction, y1]) && check_reflection_point(mirror, y1)
      return y1
    end
  end

  nil
end

def each_coordinate(array)
  array.each_with_index do |sub_array, y|
    sub_array.each_with_index do |_, x|
      yield y, x
    end
  end
end

mirrors = read

line_count = mirrors.map do |mirror|
  vertical_reflection_point_index = find_reflection_point_index(mirror.transpose)
  if !vertical_reflection_point_index.nil?
    vertical_reflection_point_index + 1
  else
    horizontal_reflection_point_index = find_reflection_point_index(mirror)
    (horizontal_reflection_point_index + 1) * 100
  end
end.sum

pp line_count

diff_line_count = mirrors.map do |mirror|
  memo = {}

  index = find_reflection_point_index(mirror.transpose)
  memo[[:vertical, index]] = true if !index.nil?
  index = find_reflection_point_index(mirror)
  memo[[:horizontal, index]] = true if !index.nil?

  direction = nil
  index = nil
  each_coordinate(mirror) do |y, x|
    # try
    mirror[y][x] = mirror[y][x] == '.' ? '#' : '.'

    # check
    direction = :vertical
    index = find_reflection_point_index_memo(memo, :vertical, mirror.transpose)
    break if !index.nil?

    direction = :horizontal
    index = find_reflection_point_index_memo(memo, :horizontal, mirror)
    break if !index.nil?

    # revert
    mirror[y][x] = mirror[y][x] == '.' ? '#' : '.'
  end

  if direction == :vertical
    index + 1
  else
    (index + 1) * 100
  end
end

pp diff_line_count.sum
