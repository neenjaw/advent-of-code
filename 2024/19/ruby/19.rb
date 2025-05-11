require "set"
require 'pqueue'
require 'pry'
require 'memoist'

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

towels_in, patterns_in = File.read(file).split("\n\n")

towels = towels_in.split(", ").to_set
patterns = patterns_in.split("\n")


def possible?(pattern, towels)
  i = pattern.size
  while i > 0
    segment = pattern[0...i]
    if towels.include?(segment)
      remaining = pattern[i..]

      return [segment] if remaining.empty?

      result = possible?(remaining, towels)

      return [segment] + result if result
    end
    i -= 1
  end

  false
end

possible = patterns.map { |pattern| [pattern, possible?(pattern, towels)] }.select { |(pattern, result)| result }

pp possible.map { |pattern, result| [pattern, result.join(", ")] }

puts possible.length




class SuperPossible
  extend Memoist

  attr_reader :towels

  def initialize(towels)
    @towels = towels
  end

  memoize def possible?(pattern)
    towels.sum do |towel|
      if pattern == towel
        1
      elsif pattern.start_with?(towel)
        possible?(pattern[towel.size..])
      else
        0
      end
    end
  end

  def really_possible?(patterns)
    patterns.map { |pattern| [pattern, possible?(pattern)] }.sum { |pattern, result| result }
  end
end

sp = SuperPossible.new(towels)

possible = sp.really_possible?(patterns)

puts possible
