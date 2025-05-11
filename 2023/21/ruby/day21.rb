require 'set'

def process_input
  input = ARGF.read.chomp.split("\n")

  garden = {}
  start = nil
  x_len = input[0].length
  y_len = input.length

  input.each_with_index do |line, y|
    line.chars.each_with_index do |ch, x|
      garden[[x, y]] = ch
      start = [x, y] if ch == 'S'
    end
  end

  return garden, start, x_len, y_len
end

def take_steps(step_limit, start, garden)
  stepped_to = Set.new([start])
  y_len = garden.keys.map { |_x, y| y }.max + 1
  x_len = garden.keys.map { |x, _y| x }.max + 1

  step_limit.times do
    stepped_to = take_a_step(stepped_to, garden, y_len, x_len)
  end

  return stepped_to
end

def take_a_step(from_steps, garden, y_len, x_len)
  to_steps = Set.new
  adjust = {'E' => [1, 0], 'W' => [-1, 0], 'S' => [0, 1], 'N' => [0, -1]}

  from_steps.each do |pos|
    'NWES'.each_char do |dir|
      new_pos = adjust_pos(pos, adjust[dir])
      next if garden_ch(new_pos, garden, y_len, x_len) == '#'
      to_steps.add(new_pos)
    end
  end

  return to_steps
end

def adjust_pos(coord, adjust)
  x, y = coord
  ax, ay = adjust
  return [x + ax, y + ay]
end

def garden_ch(coord, garden, y_len, x_len)
  x, y = coord
  a = x % x_len
  b = y % y_len
  return garden[[a, b]]
end

def analyze_result(plots_reached, x_len, y_len, n)
  puts 'Analyzing for N = ' + n.to_s
  puts 'Total plots reached: ' + plots_reached.length.to_s
  min_x, min_y, max_x, max_y = 0, 0, 0, 0

  plots_reached.each do |x, y|
    min_x = [min_x, x].min
    min_y = [min_y, y].min
    max_x = [max_x, x].max
    max_y = [max_y, y].max
  end

  squares = ((max_x - min_x + 1) / x_len).to_i
  puts 'Area reached is ' + squares.to_s + ' x ' + squares.to_s

  square_totals = []
  x = min_x
  y = min_y

  squares.times do
    row = []
    squares.times do
      plots = 0
      (x...x+x_len).each do |x1|
        (y...y+y_len).each do |y1|
          plots += 1 if plots_reached.include?([x1, y1])
        end
      end
      row << plots
      x += x_len
    end
    square_totals << row
    x = min_x
    y += y_len
  end

  return square_totals
end

def calculate_plots(squares, n)
  plots = 0

  full_odd = squares[2][2]
  full_even = squares[2][1]
  s1 = squares[0][1] + squares[0][3] + squares[4][1] + squares[4][3]
  s2 = squares[0][2] + squares[2][0] + squares[2][4] + squares[4][2]
  s3 = squares[1][1] + squares[1][3] + squares[3][1] + squares[3][3]

  plots = (s1 * n) + s2 + (s3 * (n-1)) + (full_even * n**2) + (full_odd * (n-1)**2)
  return plots
end

garden, start, x_len, y_len = process_input

garden_width = x_len
half_width = ((x_len - 1) / 2).to_i

puts 'Taking steps...'
n = 2
plots_reached = take_steps(half_width + garden_width * n, start, garden)
squares = analyze_result(plots_reached, x_len, y_len, n)

squares.each do |row|
  puts row.inspect
end

target_steps = 26501365
n = ((target_steps - half_width) / garden_width).to_i
puts 'Answer requires N = ' + n.to_s

final_plots = calculate_plots(squares, n)

puts 'Plots reached: ' + final_plots.to_s
