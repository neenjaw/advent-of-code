require "set"

files = [
  "example",
  "input"
]

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

data = files.map do |file|
  [file, File.readlines(file).map(&:chomp)]
end.to_h

input = data[file].map do |line|
  goal, factors = line.split(": ")
  goal = goal.to_i
  factors = factors.split(" ").map { |f| f.to_i }
  [goal, factors]
end

def do_calc(goal, factors, acc, concat)
  return goal if factors.empty? and acc == goal
  return nil if factors.empty?

  term = factors.shift

  do_calc(goal, factors.dup, acc + term, concat) ||
    do_calc(goal, factors.dup, acc * term, concat) ||
    (concat ? do_calc(goal, factors.dup, "#{acc}#{term}".to_i, concat) : nil)
end

def calc(input, concat = false)
  input.sum do |goal, factors|
    term = factors.shift
    do_calc(goal, factors, term, concat) || 0
  end
end

if part == 1
  ans = calc(input)
  puts ans
  exit
end

if part == 2
  ans = calc(input, true)
  puts ans
  exit
end
