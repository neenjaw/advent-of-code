# frozen_string_literal: true

require 'set'

v = ARGF.read.chomp.split("\n").map do |line|
  value, = line.chars.reverse.reduce([0, 0]) do |(value, place), c|
    d =
      case c
      when '-'
        -1 * (5**place)
      when '='
        -2 * (5**place)
      else
        c.to_i * (5**place)
      end

    # pp d

    [value + d, place + 1]
  end

  pp value

  value
end.sum

v5 = v.to_s(5)

p [:v, v, v5]

r, = v5.chomp.chars.reverse.reduce(['', 0]) do |(acc, carry), c|
  v = c.to_i

  case [v, carry]
  when [0, 0], [1, 0], [2, 0]
    next ["#{v}#{acc}", 0]
  when [0, 1], [1, 1]
    next ["#{v + 1}#{acc}", 0]
  when [2, 1], [3, 0]
    next ["=#{acc}", 1]
  when [3, 1], [4, 0]
    next ["-#{acc}", 1]
  when [4, 1]
    next ["-#{acc}", 2]
  end
end

pp r
