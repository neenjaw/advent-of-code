require 'set'

def read_universe
  universe = []
  ARGF.each_line do |line|
    universe << line.chomp.chars
  end
  universe
end

def expand_universe_rows(universe)
  universe.map do |row|
    if row.all? { |element| element == '.' }
      [row, row]
    else
      [row]
    end
  end.flatten(1)
end

def find_interstellar_gap_rows(universe)
  interstellar_gap_rows = []

  universe.each_with_index do |row, y|
    if row.all? { |element| element == '.' }
      interstellar_gap_rows << y
    end
  end

  interstellar_gap_rows
end

def find_galaxies(universe)
  galaxies = Set.new

  universe.each_with_index do |row, y|
    row.each_with_index do |element, x|
      if element == '#'
        galaxies << [y, x]
      end
    end
  end

  galaxies
end

def manhattan_distance(galaxy_a, galaxy_b)
  y1, x1 = galaxy_a
  y2, x2 = galaxy_b

  (y1 - y2).abs + (x1 - x2).abs
end

def manhattan_distance_plus(a, b, gap_rows, gap_cols, gap_multiplier = 1_000_000)
  y1, y2 = [a[0], b[0]].sort
  x1, x2 = [a[1], b[1]].sort

  y_gaps = gap_rows.count { |y| y1 < y && y < y2 }
  x_gaps = gap_cols.count { |x| x1 < x && x < x2 }

  (y1 - (y2 + (y_gaps * gap_multiplier - y_gaps))).abs + (x1 - (x2 + (x_gaps * gap_multiplier - x_gaps))).abs
end

universe = read_universe

expanded_universe = expand_universe_rows(expand_universe_rows(universe).transpose).transpose
expanded_galaxies = find_galaxies(expanded_universe)
expanded_galaxy_pairs = expanded_galaxies.to_a.combination(2).to_a
expanded_galaxy_distances = expanded_galaxy_pairs.map { |galaxy_pair| manhattan_distance(*galaxy_pair) }

interstellar_gap_rows = find_interstellar_gap_rows(universe)
interstellar_gap_columns = find_interstellar_gap_rows(universe.transpose)

galaxies = find_galaxies(universe)
galaxy_pairs = galaxies.to_a.combination(2).to_a
old_galaxy_distances = galaxy_pairs.map { |(a, b)| manhattan_distance_plus(a, b, interstellar_gap_rows, interstellar_gap_columns) }

pp expanded_galaxy_distances.sum
pp old_galaxy_distances.sum
