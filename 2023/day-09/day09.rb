# 0 3 6 9 12 15
# 1 3 6 10 15 21
# 10 13 16 21 30 45

t_minus, t_plus = ARGF.read.chomp.split("\n").map do |line|
  history = line.split.map(&:to_i)
  layers = [history]

  while layers[-1].any? { |x| x != 0 }
    prev_layer = layers[-1]
    next_layer = []

    prev_layer.each_cons(2).each do |a, b|
      next_layer << (b - a)
    end

    layers << next_layer
  end

  layers[-1] << 0
  l2 = layers.reverse.each_cons(2) do |(a, b)|
    addend = a.last + b.last
    b << addend
  end.reverse

  layers[-1].unshift(0)
  l3 = l2.reverse.each_cons(2) do |(a, b)|
    difference = b.first - a.first
    b.unshift(difference)
  end.reverse
end
.map(&:first)
.map { |x| [x.first, x.last] }
.transpose
.map(&:sum)

pp t_minus
pp t_plus
