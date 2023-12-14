require 'set'

# O....#....
# O.OO#....#
# .....##...
# OO.#O....O
# .O.....O#.
# O.#..O.#.#
# ..O..#O..O
# .......O..
# #....###..
# #OO..#....


def read
  parts = []
  ARGF.read.chomp.split("\n").each do |line|
    part = line.chars
    parts << part
  end
  parts
end

def simulate_tilt(platform)
  platform = platform.map(&:dup)

  platform.transpose.each_with_index do |col, x|
    col.each_with_index do |cell, y|
      if cell != 'O'
        next
      end

      while y > 0 && col[y-1] == '.'
        col[y-1] = 'O'
        col[y] = '.'
        y -= 1
      end
    end
  end.transpose
end

def sum_weights(platform)
  height = platform.length

  platform.each_with_index.sum do |row, y|
    row.count('O') * (height - y)
  end
end

def simulate_cycle(platform, iter = 4, start_dir = :north)
  cycle = [:north, :west, :south, :east].cycle
  while cycle.peek != start_dir
    cycle = cycle.next
  end

  iter.times do |i|
    current = cycle.peek
    # puts "current: #{current} iter: #{i}"
    platform = simulate_tilt(platform)
    # puts platform.map(&:join).join("\n")
    # puts "\n\n"

    platform = platform.reverse.transpose
    current = cycle.next

    # puts "rotated to: #{current} iter: #{i}"
    # puts platform.map(&:join).join("\n")
    # puts "\n\n"
  end

  while cycle.peek != start_dir
    platform = platform.reverse.transpose
    cycle.next
  end
  platform
end

platform = read

puts platform.map(&:join).join("\n")
puts "\n\n"

tilted = simulate_tilt(platform)

puts tilted.map(&:join).join("\n")
pp sum_weights(tilted)
puts "\n\n"

n = 3

spun = simulate_cycle(platform,  n * 4)

memo = {}
memo[spun] = 0

done = false
iter = 0
while !done
  iter += 1
  pp iter if iter % 100 == 0
  spun = simulate_cycle(spun)
  if memo.key?(spun)
    done = true
  else
    memo[spun] = iter
  end
end

pp iter
pp nn = memo[spun]
remaining = ((1_000_000_000 - iter - 3) % (iter - nn))

pp remaining

(remaining).times do
  spun = simulate_cycle(spun)
end

pp sum_weights(spun)

# puts spun.map(&:join).join("\n")
