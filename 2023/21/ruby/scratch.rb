x = 26501365 % 131
y = (26501365 - 65).to_f / 131

# 404601
# z = ((26501365 + 26501365 + 1 + 1)/2) ** 2

pp x, y


input = ARGF.read
width = input.index("\n")

pp width
middle = 65

puts '-' * width

def is_first_third(dimension, row, index)
  middle = (dimension / 2)
  index < (middle - row).abs
end

def is_second_third(dimension, row, index)
  reversed_index = dimension - index - 1
  middle = (dimension / 2)
  index > (middle - row).abs && reversed_index > (middle - row).abs
end

def is_last_third(dimension, row, index)
  reversed_index = dimension - index - 1
  middle = (dimension / 2)
  reversed_index < (middle - row).abs
end

def is_middle(dimension, row)
  middle = (dimension / 2)
  row == middle
end

def is_top_half(dimension, row)
  middle = (dimension / 2)
  row < middle
end

def is_bottom_half(dimension, row)
  middle = (dimension / 2)
  row > middle
end

def print_grid(dimension)
  dimension.times do |row|
    dimension.times do |index|
      if is_middle(dimension, row)
        print 'm'
      elsif is_first_third(dimension, row, index)
        print '-'
      elsif is_last_third(dimension, row, index)
        print '+'
      elsif is_second_third(dimension, row, index)
        print '*'
      else
        print '.'
      end
    end
    puts ''
  end
end

print_grid(5)

def determine_direction(dimension, row, index)
  if is_first_third(dimension, row, index)
    if is_top_half(dimension, row)
      :nw
    else
      :sw
    end
  elsif is_second_third(dimension, row, index)
    if is_top_half(dimension, row)
      :n
    else
      :s
    end
  elsif is_last_third(dimension, row, index)
    if is_top_half(dimension, row)
      :ne
    else
      :se
    end
  end
end

def color(direction, c)
  case direction
  when :nw
    return "\e[31m#{c}\e[0m"
  when :n
    return "\e[32m#{c}\e[0m"
  when :ne
    return "\e[33m#{c}\e[0m"
  when :sw
    return "\e[34m#{c}\e[0m"
  when :s
    return "\e[35m#{c}\e[0m"
  when :se
    return "\e[36m#{c}\e[0m"
  when :m
    return "\e[37m#{c}\e[0m"
  end
end


e, o = Set.new, Set.new
flip = true
row = 0
index = 0
stones = {
  nw: {
    e: 0,
    o: 0,
    s: Set.new
  },
  n: {
    e: 0,
    o: 0,
    s: Set.new
  },
  ne: {
    e: 0,
    o: 0,
    s: Set.new
  },
  sw: {
    e: 0,
    o: 0,
    s: Set.new
  },
  s: {
    e: 0,
    o: 0,
    s: Set.new
  },
  se: {
    e: 0,
    o: 0,
    s: Set.new
  }
}
grid = [[]]
input.chars.each do |c|
  if c == "\n"
    row += 1
    index = 0
    grid << []
    next
  end

  grid.last << c

  if c == '.' || c == 'S'
    if flip
      e << [row, index]
    else
      o << [row, index]
    end
  end

  if c == '#'
    direction = determine_direction(width, row, index)
    stones[direction][flip ? :e : :o] += 1
    stones[direction][:s] << [row, index]
  end

  flip = !flip
  index += 1
end

def print_grid_stones(grid, stones, even, odd)
  width = grid.first.length
  middle = (width / 2)
  pp middle

  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if cell == '#'
        direction = determine_direction(grid.first.length, y, x)
        if !direction.nil?
          print color(direction, cell)
        else
          print cell
        end
      elsif cell == 'S'
        print color(:m, cell)
      elsif (y - middle).abs + (x - middle).abs == middle || y == middle
        print color(:m, 'x')
      elsif odd.include?([y, x])
        print '.'
      else
        print ' '
      end
    end
    puts ''
  end
end

print_grid_stones(grid, stones, e, o)

# These are all wrong. Went 1 step too far..... :( :( :(
steps_visited = [
  [65, 3585],
  [196, 32173],
  [327, 90909],
  [458, 177201],
  [589, 294953],
  [720, 438949],
  [851, 615717],
  [982, 817417],
  [1113, 1053201],
  [1244, 1312605]
]
