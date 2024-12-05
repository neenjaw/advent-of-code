require "set"

files = [
  "example.txt",
  "input.txt"
]

data = files.map do |file|
  [file, File.readlines(file).map(&:chomp)]
end.to_h

grids = data.map do |file, lines|
  grid = lines.map do |line|
    line.split("")
  end

  [file, grid]
end.to_h

WORD = "XMAS".split("")

def valid_coord?(grid, y, x)
  y >= 0 && x >= 0 && y < grid.length && x < grid[y].length
end

def check_word(word, grid, y, x, direction)
  dy, dx = direction
  word.each do |letter|
    return false if !valid_coord?(grid, y, x)
    return false if grid[y][x] != letter

    y, x = [y + dy, x + dx]
  end

  true
end

def search_around(grid, y, x)
  directions = [
    [-1, 0], [1, 0], [0, -1], [0, 1], [1, 1], [-1, -1], [1, -1], [-1, 1]
  ]

  directions.count do |direction|
    check_word(WORD, grid, y, x, direction)
  end
end

def search(grid)
  grid.each_with_index.sum do |row, y|
    row.each_with_index.sum do |cell, x|
      next 0 if cell != "X"
      search_around(grid, y, x)
    end
  end
end

puts search(grids['example.txt'])
puts search(grids['input.txt'])

MS_SET = Set.new("MS".split(""))

def search_around2(grid, y, x)
  ltr_directions = [
    [-1, -1], [1, 1],
  ]
  elems = ltr_directions
    .map { |dy, dx| [y + dy, x + dx] }
    .select { |y, x| valid_coord?(grid, y, x) }
    .map { |y, x| grid[y][x] }
    .to_set
  has_ltr = elems == MS_SET

  rtl_directions = [
    [-1, 1], [1, -1]
  ]
  elems = rtl_directions
    .map { |dy, dx| [y + dy, x + dx] }
    .select { |y, x| valid_coord?(grid, y, x) }
    .map { |y, x| grid[y][x] }
    .to_set
  has_rtl = elems == MS_SET

  has_ltr && has_rtl
end

def search2(grid)
  grid.each_with_index.sum do |row, y|
    row.each_with_index.count do |cell, x|
      next false if cell != "A"
      search_around2(grid, y, x)
    end
  end
end

puts search2(grids['example.txt'])
puts search2(grids['input.txt'])
