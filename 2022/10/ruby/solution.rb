require 'set'

instructions = ARGF.read.chomp.split(/\n/).map do |line|
  instruction, amount_str = line.split(/ /)
  amount = amount_str.nil? ? nil : amount_str.to_i
  [instruction, amount]
end

cycles = [20, 60, 100, 140, 180, 220]

class Display
  attr_reader :px

  def initialize
    @cycle = 0
    @x = 1
    @px = []
  end

  def simulate(instructions, cycles_to_watch)
    record = {}

    instructions.each do |(instruction, v)|
      # pp instruction, v

      case instruction
      when "noop"
        handle_noop { amend_record(record, cycles_to_watch) }
      when "addx"
        handle_addx(v) { amend_record(record, cycles_to_watch) }
      else
        raise "whaaaaaa"
      end
    end

    pp record
  end

  def handle_noop
    draw            # start
    @cycle += 1
    yield @x        # mid
  end

  def handle_addx(v)
    draw            # start
    @cycle += 1
    yield @x        # mid

    draw            # start
    @cycle += 1
    yield @x        # mid
    @x += v         # end
  end

  def draw
    if sprite_overlap?
      @px << "#"
    else
      @px << " "
    end
  end

  def sprite_overlap?
    [@x - 1, @x, @x + 1].include?(@cycle % 40)
  end

  def picture
    @px.each_slice(40).map(&:join).join("\n")
  end

  def amend_record(record, cycles_to_watch)
    record[@cycle] = @x if cycles_to_watch.include?(@cycle)
  end
end

# pp Display.new.simulate(instructions, cycles).map {|k, v| k * v }.sum

d = Display.new
d.simulate(instructions, cycles)
puts d.picture

