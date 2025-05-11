require "set"
require "matrix"

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

input = File.read(file).split("\n").map do |line|
  matches = /p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/.match(line)
  px, py, vx, vy = matches.captures.map(&:to_i)

  { px: px, py: py, vx: vx, vy: vy }
end

MAX_W = file=='input' ? 101 : 11
MAX_H = file=='input' ? 103 : 7

def compute_positions(robot, time = 100)
    x = robot[:px] + time * robot[:vx]
    y = robot[:py] + time * robot[:vy]

    x = x % MAX_W
    y = y % MAX_H

    { px: x, py: y, vx: robot[:vx], vy: robot[:vy] }
end

def compute_safety_margin(robots, width = MAX_W, height = MAX_H)
  quadrants = Array.new(4, 0)

  robots.each do |robot|
    x, y = robot[:px], robot[:py]

    if x < width / 2 && y < height / 2
      quadrants[0] += 1
    elsif x > width / 2 && y < height / 2
      quadrants[1] += 1
    elsif x < width / 2 && y > height / 2
      quadrants[2] += 1
    elsif x > width / 2 && y > height / 2
      quadrants[3] += 1
    end
  end

  pp quadrants

  quadrants.reduce(:*)
end

def print(robots, width = MAX_W, height = MAX_H)
  grid = Array.new(height) { Array.new(width, ".") }

  robots.each do |robot|
    current = grid[robot[:py]][robot[:px]]
    grid[robot[:py]][robot[:px]] = current == "." ? 1 : current + 1
  end

  grid[height / 2].map! { " " }
  grid.each { |row| row[width / 2] = " " }

  grid.each do |row|
    puts row.join
  end
end

positioned = input.map { |r| compute_positions(r) }

pp positioned
print(positioned)
puts compute_safety_margin(positioned)

seconds = 0
easter_egg = input
loop do
  iteration_coord_frequencies = Hash.new(0)

  easter_egg = easter_egg.map do |robot|
    r1 = compute_positions(robot, 1)
    iteration_coord_frequencies[[r1[:px], r1[:py]]] += 1
    r1
  end

  seconds += 1
  break if iteration_coord_frequencies.values.all? { |v| v == 1 }
end

p seconds
print(easter_egg)
