require 'set'

instructions = ARGF.read.chomp.split(/\n/).map do |line|
  direction, amount_str = line.split(/ /)
  amount = amount_str.to_i
  [direction, amount]
end

class Knot
  attr_reader :t
  attr_writer :child

  def initialize(child = nil)
    @h = [0,0]
    @t = [0,0]
    @tail_history = Set.new([@h])
    @tail_detailed_history = [@h]
    @child = nil
  end

  def simulate(steps)
    steps.each { |(direction, amount)| amount.times { move(direction) } }

    self
  end

  def move(direction)
    x, y = @h
    case direction
    when "U"
      y -= 1
    when "D"
      y += 1
    when "L"
      x -= 1
    when "R"
      x += 1
    else
      raise "missed case #{direction}"
    end

    @h = [x, y]
    update_tail
    self
  end

  def move_to(c)
    @h = c
    update_tail
    self
  end

  def update_tail
    hx, hy = @h
    tx, ty = @t

    dx = hx - tx
    dy = hy - ty

    has_x_space = dx.abs > 1
    has_y_space = dy.abs > 1

    if has_x_space
      tx += dx < 0 ? -1 : 1
    end

    if has_y_space
      ty += dy < 0 ? -1 : 1
    end

    if has_x_space and has_y_space
      nil
    elsif dx.abs > 0 and has_y_space
      tx = hx
    elsif dy.abs > 0 and has_x_space
      ty = hy
    end

    # case [dx.abs, dy.abs]
    # when [2, 1]
    #   ty += dy
    #   tx += dx.div(2)
    # when [1, 2]
    #   ty += dy.div(2)
    #   tx += dx
    # when [2, 0]
    #   tx += dx.div(2)
    # when [0, 2]
    #   ty += dy.div(2)
    # when [2, 2]
    #   tx += dx.div(2)
    #   ty += dy.div(2)
    # when [0, 1], [0, 0], [1,1], [1,0]
    #   nil
    # else
    #   raise "#{dx} #{dy}"
    # end

    @t = [tx, ty]
    # pp "h: #{@h} t: #{@t}"
    @tail_history.add(@t)
    @tail_detailed_history << @t

    @child.move_to(@t) if @child

    self
  end

  def tail_history_size
    # pp @tail_history
    @tail_history.size
  end
end

class Knots
  attr_reader :rope

  def initialize(size = 9)
    @rope = Array.new(9) { Knot.new }
    @rope.reverse.reduce do |prev_knot, knot|
      knot.child = prev_knot
      knot
    end
  end

  def simulate(steps)
    steps.each do |(direction, amount)|
      amount.times { @rope.first.move(direction) }
    end

    self
  end

  def tail_history_size
    @rope.last.tail_history_size
  end
end

pp Knot.new.simulate(instructions).tail_history_size

ks =  Knots.new.simulate(instructions)

pp ks.rope.last.tail_history_size
# 2341 # 2355