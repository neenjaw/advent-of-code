# frozen_string_literal: true

require 'set'

Point = Struct.new(:y, :x)
Blizzard = Struct.new(:y, :x, :dy, :dx)

wall_acc = Set.new
BLIZZARDS = Set.new

ARGF.read.chomp.split("\n").each_with_index do |line, y|
  line.chars.each_with_index do |c, x|
    case c
    when '#'
      wall_acc.add(Point.new(y - 1, x - 1))
    when '<'
      BLIZZARDS.add(Blizzard.new(y - 1, x - 1, 0, -1))
    when '>'
      BLIZZARDS.add(Blizzard.new(y - 1, x - 1, 0, 1))
    when '^'
      BLIZZARDS.add(Blizzard.new(y - 1, x - 1, -1, 0))
    when 'v'
      BLIZZARDS.add(Blizzard.new(y - 1, x - 1, 1, 0))
    when '.'
      nil
    else
      raise "unhandled: #{c}"
    end
  end
end

MAX_X = wall_acc.map(&:x).max
MAX_Y = wall_acc.map(&:y).max
P_START = Point.new(-1, 0)
P_END = Point.new(MAX_Y, MAX_X - 1)

WALLS = wall_acc | (-1..3).map { Point.new(-2, _1) }.to_set | ((MAX_X - 3)..MAX_X + 2).map { Point.new(MAX_Y + 1, _1) }.to_set

time = 0
queue = [P_START].to_set
goals = [P_END, P_START, P_END]

until goals.empty?
  time += 1

  adjusted_blizzards = BLIZZARDS.to_a.map do |b|
    Point.new(((time * b.dy) + b.y) % MAX_Y, ((time * b.dx) + b.x) % MAX_X)
  end.to_set

  possible_steps = queue.to_a.flat_map do |p|
    [[1, 0], [-1, 0], [0, 1], [0, -1], [0, 0]].map do |(dy, dx)|
      Point.new(p.y + dy, p.x + dx)
    end
  end.to_set

  queue = possible_steps - adjusted_blizzards - WALLS

  if queue.include?(goals.first)
    puts "goal #{goals.first} reached in #{time} steps"
    queue = [goals.shift].to_set
  end
end
