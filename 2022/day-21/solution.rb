require 'set'

class Solution
  attr_reader :input

  def initialize(input)
    @input = input.chomp
      .split("\n")
      .map(&:to_i)
  end
end

solution = Solution.new(ARGF.read)


