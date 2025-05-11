# Advent of Code 2023, Day 3
#
# Grid:
# 467..114..
# ...*......
# ..35..633.
# ......#...
# 617*......
# .....+.58.
# ..592.....
# ......755.
# ...$.*....
# .664.598..

grid = []

ARGF.each_line do |line|
  grid << line.chomp.chars

end

numbers = []

def find_number(grid, y, x)
  dstart = x
  dend = x

  while grid[y][dstart-1] =~ /\d/ || grid[y][dend+1] =~ /\d/
    if (dstart - 1) >= 0 && grid[y][dstart-1] =~ /\d/
      dstart -= 1
    end

    if (dend + 1) < grid[y].length && grid[y][dend+1] =~ /\d/
      dend += 1
    end
  end

  grid[y][dstart..dend].join.to_i
end

def look_around_cell(grid, y, x)
  local_numbers = []

  if grid[y-1][x] =~ /\d/
    local_numbers << find_number(grid, y-1, x)
  else
    if grid[y-1][x-1] =~ /\d/
      local_numbers << find_number(grid, y-1, x-1)
    end
    if grid[y-1][x+1] =~ /\d/
      local_numbers << find_number(grid, y-1, x+1)
    end
  end

  if grid[y+1][x] =~ /\d/
    local_numbers << find_number(grid, y+1, x)
  else
    if grid[y+1][x-1] =~ /\d/
      local_numbers << find_number(grid, y+1, x-1)
    end
    if grid[y+1][x+1] =~ /\d/
      local_numbers << find_number(grid, y+1, x+1)
    end
  end

  if grid[y][x-1] =~ /\d/
    local_numbers << find_number(grid, y, x-1)
  end
  if grid[y][x+1] =~ /\d/
    local_numbers << find_number(grid, y, x+1)
  end

  local_numbers.compact
end

grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    if cell =~ /[^\d.]/
      numbers << look_around_cell(grid, y, x)
    end
  end
end


pp numbers.flatten.sum
pp numbers.filter { |n| n.length == 2 }.map { |n| n.inject(:*) }.flatten.sum
