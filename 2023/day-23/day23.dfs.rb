require 'set'

lines = File.readlines('input.txt').map(&:chomp)

n, m = lines.size, lines[0].size


def neighbors(pos, lines, n, m)
  i, j = pos
  case lines[i][j]
  when '>'
    [[i, j + 1]]
  when '<'
    [[i, j - 1]]
  when '^'
    [[i - 1, j]]
  when 'v'
    [[i + 1, j]]
  else
    neighbors_spot = [[i - 1, j], [i + 1, j], [i, j - 1], [i, j + 1]]
    if lines[i][j] == '.'
      neighbors_spot.select do |i, j|
        i >= 0 && j >= 0 && i < n && j < m && lines[i][j] != '#'
      end
    end
  end
end

def dfs(start, finish, init_dist, visited, lines, n, m)
  return [init_dist] if start == finish

  neighbors(start, lines, n, m).each_with_object([]) do |v, paths|
    unless visited.include?(v)
      visited.add(v)
      paths.concat(dfs(v, finish, init_dist + 1, visited, lines, n, m))
      visited.delete(v)
    end
  end
end

deb = [0, 1]
fin = [n - 1, m - 2]

puts "Part 1: #{dfs(deb, fin, 0, Set.new([deb]), lines, n, m).max}"

def neighbors2(pos, lines, n, m)
  i, j = pos
  neighbors_spot = [[i - 1, j], [i + 1, j], [i, j - 1], [i, j + 1]]
  neighbors_spot.select do |i, j|
    i >= 0 && j >= 0 && i < n && j < m && lines[i][j] != '#'
  end
end

bifurcations = [deb] +
  (0...n).flat_map { |i| (0...m).map { |j| [i, j] if neighbors2([i, j], lines, n, m).size > 2 } }.compact +
  [fin]

g = Hash.new { |h, k| h[k] = [] }
bifurcations.each do |b|
  neighbors2(b, lines, n, m).each do |v|
    previous, cur, d = b, v, 1
    until bifurcations.include?(cur)
      previous, cur = cur, (neighbors2(cur, lines, n, m) - [previous]).first
      d += 1
    end
    g[b] << [cur, d]
  end
end

def dfs2(start, finish, init_dist, visited, g)
  return [init_dist] if start == finish

  g[start].each_with_object([]) do |(v, d), paths|
    unless visited.include?(v)
      visited.add(v)
      paths.concat(dfs2(v, finish, init_dist + d, visited, g))
      visited.delete(v)
    end
  end
end

puts "Part 2: #{dfs2(deb, fin, 0, Set.new([deb]), g).max}"
