x_max, y_min = ARGF.read.chomp.split("\n")
  .map do |line|
    line.chomp.split.drop(1)
  end
  .map(&:join)
  .map(&:to_i)

r1 = (x_max - Math.sqrt(x_max**2 - 4 * y_min)) / 2
r2 = (x_max + Math.sqrt(x_max**2 - 4 * y_min)) / 2

pp (r1 - r2).to_i.abs
