require 'set'

# #.#.### 1,1,3
# .#...#....###. 1,1,3
# .#.###.#.###### 1,3,1,6
# ####.#...#... 4,1,1
# #....######..#####. 1,6,5
# .###.##....# 3,2,1

# ???.### 1,1,3
# .??..??...?##. 1,1,3
# ?#?#?#?#?#?#?#? 1,3,1,6
# ????.#...#... 4,1,1
# ????.######..#####. 1,6,5
# ?###???????? 3,2,1


def read
  lines = []
  ARGF.each_line do |line|
    pattern, ns = line.chomp.split
    counts = ns.split(',').map(&:to_i)

    lines << [pattern.chars, counts]
  end
  lines
end

def compute_possibilities(row)
  possibilities = []
  unknown_cells = row[0].count('?') # Count the number of empty cells in the row
  options = ['#', '.']
  all_permutations = options.repeated_permutation(unknown_cells).to_a

  [all_permutations, *row ]
end

def substitute_possibilities(possibilities, pattern)
  possibilities.map do |possibility|
    pattern.map { |c| c == '?' ? possibility.shift : c}
  end
end

def get_subgroup_size(group)
  split_group = group.join.sub(/^\.+/, '').sub(/\.+$/, '').split(/\.+/)
  split_group.map { |sg| sg.count('#') }
end

def each_group(array)
  i = 0
  array.chunk { |c| c }.each do |char, group|
    yield [group, i] if char == '#'
    i += 1
  end
end

lines = read

total = lines.map.with_index do |row, i|
  possibilities, pattern, counts = compute_possibilities(row)
  substituted_possibilities = substitute_possibilities(possibilities, pattern)

  valid_count = 0
  i = 0

  substituted_possibilities.inject(0) do |valid_count, possibility|
    chunks = possibility.chunk { |c| c }.select { |char, group| char == '#' }.map { |char, group| group.length }
    valid_count += 1 if chunks == counts
    valid_count
  end
end.sum

pp total
