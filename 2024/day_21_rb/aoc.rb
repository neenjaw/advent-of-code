require "set"
require 'pry'
require 'matrix'

file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
ARGV.clear

puts "file: #{file}"

codes = File.readlines(file).map(&:chomp)

door_control = [
  [Vector[0,0], '7'],
  [Vector[0,1], '8'],
  [Vector[0,2], '9'],
  [Vector[1,0], '4'],
  [Vector[1,1], '5'],
  [Vector[1,2], '6'],
  [Vector[2,0], '1'],
  [Vector[2,1], '2'],
  [Vector[2,2], '3'],
  [Vector[3,1], '0'],
  [Vector[3,2], 'A'],
].to_h
$door_control = door_control.merge(door_control.invert)

robot_control = [
  [Vector[0, 1], '^'],
  [Vector[0, 2], 'a'],
  [Vector[1, 0], '<'],
  [Vector[1, 1], 'v'],
  [Vector[1, 2], '>'],
  ].to_h
$robot_control = robot_control.merge(robot_control.invert)

$directions = {
  '^' => Vector[-1, 0],
  'v' => Vector[1, 0],
  '<' => Vector[0, -1],
  '>' => Vector[0, 1],
}

def pathing(start, target, control_grid)
  delta = target - start
  dy, dx = delta[0], delta[1]
  string = ''
  if dx < 0
    string += '<' * dx.abs
  else
    string += '>' * dx
  end
  if dy < 0
    string += '^' * dy.abs
  else
    string += 'v' * dy
  end
  rv = string.chars.permutation.to_a.uniq
    .filter do |s|
      !s.map { $directions[_1] }
        .reduce([start]) { _1 + [_1.last + _2] }
        .any? { control_grid[_1].nil? }
    end.map { _1.join + 'a' }
  rv = ['a'] if rv == []
  return rv
end

$memo = {}
def code_to_path(code, depth = 0, limit = 2)
  # spacer = ' ' * depth * 4
  # puts spacer + "code: #{code}, depth: #{depth}"
  memo_key = [code, depth, limit]
  return $memo[memo_key] if $memo[memo_key]

  prefix = depth == 0 ? 'A' : "a"
  control_grid = depth == 0 ? $door_control : $robot_control
  blank_acc = 0
  result = (prefix + code).chars.each_cons(2).inject(blank_acc) do |acc, (c1, c2)|
    # puts spacer + "c1: #{c1}, c2: #{c2}"
    start = control_grid[c1]
    target = control_grid[c2]
    paths = pathing(start, target, control_grid)
    # puts spacer + "paths: #{paths.inspect}"
    next acc + paths.first.length if depth >= limit

    min_path = paths
      .map { code_to_path(_1, depth + 1, limit) }
      .min

    acc + min_path
  end

  $memo[memo_key] = result
  result
end

paths = codes.map { |code| [code, code_to_path(code, 0, 2)] }

x = paths.map do |(code, path)|
  numeric = code[0...-1].to_i
  length = path
  puts "code: #{code}, numeric: #{numeric}, length: #{length}, calc: #{numeric * length}"
  numeric * length
end.sum

puts "p1: #{x}"

paths2 = codes.map { |code| [code, code_to_path(code, 0, 25)] }

x2 = paths2.map do |(code, path)|
  numeric = code[0...-1].to_i
  length = path
  puts "code: #{code}, numeric: #{numeric}, length: #{length}, calc: #{numeric * length}"
  numeric * length
end.sum

puts "p2: #{x2}"
