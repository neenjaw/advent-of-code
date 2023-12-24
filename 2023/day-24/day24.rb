require 'set'
require 'io/console'

# 19, 13, 30 @ -2,  1, -2
# 18, 19, 22 @ -1, -1, -2
# 20, 25, 34 @ -2, -2, -4
# 12, 31, 28 @ -1, -2, -1
# 20, 19, 15 @  1, -5, -3

def read
  lines = []
  ARGF.read.chomp.split("\n").each_with_index do |line, idx|
    line =~ /(\d+),\s+(\d+),\s+(\d+)\s+@\s+(-?\d+),\s+(-?\d+),\s+(-?\d+)/
    px, py, pz, vx, vy, vz = $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i

    lines << {px: px, py: py, _pz: pz, vx: vx, vy: vy, _vz: vz }
  end
  lines
end

# Aborting, going to use python instead.... :(
