require "set"
require 'pqueue'
require 'pry'

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

Machine = Struct.new(:ra, :rb, :rc, :program, :buffer) do
  def initialize(ra, rb, rc, program, buffer = [])
    super(ra, rb, rc, program, buffer)
    @pointer = 0
  end

  def opcode_to_method(opcode)
    case opcode
    when 0 then :adv
    when 1 then :bxl
    when 2 then :bst
    when 3 then :jnz
    when 4 then :bxc
    when 5 then :out
    when 6 then :bdv
    when 7 then :cdv
    end
  end

  def combo_operand(operand)
    case operand
    when 0, 1, 2, 3 then operand
    when 4 then ra
    when 5 then rb
    when 6 then rc
    when 7 then raise "Invalid operand value: 7"
    end
  end

  def adv(operand)
    numerator = ra
    denominator = 2**combo_operand(operand)
    val = numerator / denominator
    puts "adv: #{ra} / 2**#{combo_operand(operand)} = #{val}" if DEBUG
    self.ra = val
  end

  def bxl(operand)
    val = rb ^ operand
    self.rb = val
  end

  def bst(operand)
    self.rb = combo_operand(operand) % 8
  end

  def jnz(operand)
    if ra != 0
      @pointer = operand
      return :jumped
    end
  end

  def bxc(operand)
    val = rb ^ rc
    self.rb = val
  end

  def out(operand)
    buffer << combo_operand(operand) % 8
  end

  def bdv(operand)
    self.rb = ra / 2**combo_operand(operand)
  end

  def cdv(operand)
    self.rc = ra / 2**combo_operand(operand)
  end

  def run
    puts "program: #{program}" if DEBUG
    while @pointer < program.length
      puts "pointer: #{@pointer} ra: #{ra}, rb: #{rb}, rc: #{rc}, buffer: #{buffer}" if DEBUG
      opcode, operand = program[@pointer], program[@pointer + 1]
      method = opcode_to_method(opcode)
      puts "opcode: #{opcode}, operand: #{operand}, method: #{method}" if DEBUG
      if send(method, operand) == :jumped
        next
      end
      @pointer += 2
      gets if DEBUG
    end
  end
end

t1 = Machine.new(0, 0, 9, [2, 6])
t1.run
raise "test 1 failed" unless t1.rb == 1

t2 = Machine.new(10, 0, 0, [5,0,5,1,5,4])
t2.run
raise "test 2 failed" unless t2.buffer == [0,1,2]

t3 = Machine.new(2024, 0, 0, [0,1,5,4,3,0])
t3.run
raise "test 3 failed" unless t3.buffer == [4,2,5,6,7,7,7,7,3,1,0] && t3.ra == 0

t4 = Machine.new(0, 29, 0, [1,7])
t4.run
raise "test 4 failed" unless t4.rb == 26

t5 = Machine.new(0, 2024, 43690, [4,0])
t5.run
raise "test 5 failed" unless t5.rb == 44354


register_input, program_input = File.read(file).split("\n\n")

a, b, c = register_input.scan(/\d+/).map(&:to_i)
puts "registers: #{a}, #{b}, #{c}" if DEBUG

program = program_input.scan(/\d+/).map(&:to_i)
puts "program: #{program}" if DEBUG

m1 = Machine.new(a, b, c, program)
m1.run
puts m1.buffer.join(",")


def part2(a, b, c, program)
  # computer = Machine.new(a, b, c, program)
  # instructions = computer.instructions

  l = 1
  i = program.length - 1
  prefixes = ['']
  while i >= 0
    puts "i: #{i}"
    puts "prefixes: #{prefixes}"
    valid_inputs = []
    (0...8).each do |digit|
      prefixes.each do |prefix|
        str_a = "#{prefix}#{digit}"
        int_a = str_a.to_i(8)
        computer = Machine.new(int_a, b, c, program)
        computer.run
        result = computer.buffer
        valid_inputs << str_a if result == program[i..]
      end
    end
    i -= 1
    prefixes = valid_inputs
    l += 1
  end

  puts "l: #{l}"
  prefixes.map { |p| p.to_i(8) }.tap { |p| puts "prefixes: #{p}" }.min
end

puts part2(a, b, c, program)
