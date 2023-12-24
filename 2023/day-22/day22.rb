require 'set'
require 'io/console'

# lazy way to generate unique labels
# bad global state, but it works
$labels = Set.new
def generate_label(ord)
  letters = ('A'..'Z').to_a
  label = ''
  while ord > 0
    ord, idx = ord.divmod(26)
    label = letters[idx - 1] + label if idx > 0
    ord -= 1 if idx == 0
  end
  label

  suffix = 0
  while $labels.include?(label+suffix.to_s)
    suffix += 1
  end

  label = (label + suffix.to_s).freeze
  $labels << label
  label
end


def get_random_ansi_color(idx)
  # 31 red
  # 32 green
  # 33 yellow
  # 34 blue
  # 35 magenta
  # 36 cyan
  colors = [31, 32, 33, 34, 35, 36]
  colors[idx % colors.size]
end

def read
  blocks = []
  ARGF.read.chomp.split("\n").each_with_index do |line, idx|
    line =~ /(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/
    x1, y1, z1, x2, y2, z2 = $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i

    raise "z1 > z2" if z1 > z2

    blocks << {
      z: z1,
      z_original: z1,
      label: idx,
      p1: {x: x1, y: y1, z: 0 },
      p2: {x: x2, y: y2, z: z2 - z1 },
      color: get_random_ansi_color(idx)
    }
  end
  blocks.sort_by { |block| block[:z_original] }
end

def find_min_z_placement(z_map, block)
  _z, p1, p2 = block[:z_original], block[:p1], block[:p2]
  z_min = 0

  (p1[:x]..p2[:x]).each do |x|
    (p1[:y]..p2[:y]).each do |y|
      z_map[[x, y]] ||= 0
      z = z_map[[x, y]]
      if z > z_min
        z_min = z
      end
    end
  end

  return z_min + 1
end

def drop_blocks(blocks)
  orig_grid = {}
  z_grid = {}
  grid = {}

  blocks.each do |block|
    z_ord = block[:z_original]
    p1 = block[:p1]
    p2 = block[:p2]
    label = block[:label]
    color = block[:color]
    z_min = find_min_z_placement(z_grid, block)

    (p1[:x]..p2[:x]).each do |x|
      (p1[:y]..p2[:y]).each do |y|
        block[:z] = z_min

        ((z_ord + p1[:z])..(z_ord + p2[:z])).each do |z|
          orig_grid[[x, y, z]] = {
            label: label,
            color: color
          }
        end

        ((z_min + p1[:z])..(z_min + p2[:z])).each do |z|
          if grid[[x, y, z]]
            # throw if there is a block already there
            raise "unexpected"
          end

          grid[[x, y, z]] = {
            label: label,
            color: color
          }
          z_grid[[x, y]] = z
        end
      end
    end
  end

  [
    grid,
    z_grid,
    blocks.to_h { |block| [block[:label], block] },
    orig_grid
  ]
end

def print_profile(grid, profile_index, profile_range, depth_index, depth_range, z_range)

  profile_label = ['x', 'y'][profile_index]
  print " " * (profile_range.size / 2) + profile_label + "\n"
  profile_range.each do |p|
    print p.to_s[-1]
  end
  print "\n"

  z_range.to_a.reverse.each do |z|
    ps = []

    profile_range.each do |pr|
      char = nil
      color = nil
      depth_range.to_a.reverse.each do |d|
        v = [-1, -1, z]
        v[profile_index] = pr
        v[depth_index] = d
        cell = grid[v][:label] rescue nil
        cell_color = grid[v][:color] rescue nil
        char = cell.chars.first unless cell.nil?
        color = cell_color unless cell_color.nil?
      end
      if char
        print "\e[#{color}m#{char}\e[0m"
      else
        print ' '
      end
    end
    print " | #{z}"
    print " #{ps.inspect}" if ps.size > 0
    print "\n"
  end
  print "=" * profile_range.size + "=| 0\n"
end

def print_grid(grid)
  x_max = grid.keys.map { |x, _y, _z| x }.max
  y_max = grid.keys.map { |_x, y, _z| y }.max
  z_max = grid.keys.map { |_x, _y, z| z }.max

  print_profile(grid, 0, (0..x_max), 1, (0..y_max), (1..z_max))
  print "\n" + "-" * 40 + "\n\n"
  print_profile(grid, 1, (0..y_max), 0, (0..x_max), (1..z_max))
end

def find_removable_blocks(grid, z_grid, lookup)
  blocks_above = Hash.new
  blocks_below = Hash.new
  grid.each do |k, v|
    x, y, z = k

    z_above = z + 1
    z_below = z - 1

    v_above = grid[[x, y, z_above]]
    v_below = grid[[x, y, z_below]]

    if !v_above.nil? && v_above[:label] != v[:label]
      blocks_above[v[:label]] ||= Set.new
      blocks_above[v[:label]] << v_above[:label]
    end

    if !v_below.nil? && v_below[:label] != v[:label]
      blocks_below[v[:label]] ||= Set.new
      blocks_below[v[:label]] << v_below[:label]
    end
  end
  [blocks_above, blocks_below]
end

blocks = read

# pp blocks

grid, z_grid, lookup, orig_grid = drop_blocks(blocks)


# print_grid(orig_grid)
# puts "\n\n"
# print_grid(grid)

blocks_positioned_above, blocks_positioned_below = find_removable_blocks(grid, z_grid, lookup)

b = lookup.keys.filter do |block|
  blocks_above = blocks_positioned_above[block]
  if blocks_above.nil?
    puts "#{block} no-child removed"
    next true
  end

  children_supported = blocks_above.all? do |ba|
    blocks_below = blocks_positioned_below[ba]
    blocks_below.size > 1
  end

  if children_supported
    puts "#{block} chilren-supported removed"
  else
    puts "#{block} children-unsupported not-removed"
  end

  children_supported
end

pp Set.new(b).size

# DEBUG - FOUND DUPLICATE LABELS :(
# groups = blocks.group_by { |block| block[:label] }.select { |label, blocks| blocks.size > 1 }


# this could probably be optimized with a dynamic programming approach
# as you go from top to bottom, you can memoize the set of blocks that are
# supported by the current block... I think
# then at every step do a set union to get the current set of blocks that can fall
memo = {}
blocks
  .sort_by { |block| block[:z] }
  .reverse
  .map do |block|
    label = block[:label]
    removed = blocks_positioned_above[label]
      .to_a
      .filter { |b| blocks_positioned_below[b].size == 1 }
      .to_set
    queue = removed.dup.to_a
    removed << label

    while !queue.empty?
      b = queue.shift

      unsupported_above = blocks_positioned_above[b]
        .to_a
        .filter do |b|
          supporting = blocks_positioned_below[b].count do |below|
            !removed.include?(below)
          end
          supporting == 0
        end

      removed += unsupported_above
      queue += unsupported_above
    end

    cost = (removed - [label]).size

    memo[block[:label]] = cost
    cost
  end

# pp memo

pp memo.values.sum
