module Solution
  def self.part1(input)
    measurements = parse(input)
    measurements.each_cons(2).count { |previous, current| current > previous }
  end

  def self.part2(input)
    measurements = parse(input)
    window_sums = measurements.each_cons(3).map(&:sum)
    window_sums.each_cons(2).count { |previous, current| current > previous }
  end

  def self.parse(input)
    input.lines.map(&:to_i)
  end
end
