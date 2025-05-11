require 'set'

input = ARGF.read

class Monkey
  attr_reader :inspection_count, :divisible_test, :items

  def initialize(items, operation, divisor, monkey_on_test_true, monkey_on_test_false)
    @inspection_count = 0
    @items = items
    @operation = operation
    @divisible_test = divisor
    @monkey_on_test_true = monkey_on_test_true
    @monkey_on_test_false = monkey_on_test_false
  end

  def step(monkeys, worry_reducer = nil)
    @items.each do |item|
      @inspection_count += 1

      worried_item = @operation.call(item)

      bored_item =
        if worry_reducer.nil?
          worried_item.div(3)
        else
          worried_item % worry_reducer
        end

      if (bored_item % @divisible_test).zero?
        monkeys[@monkey_on_test_true].receive(bored_item)
      else
        monkeys[@monkey_on_test_false].receive(bored_item)
      end
    end

    @items = []
  end

  def receive(item)
    @items << item
  end
end

class Monkeys
  attr_reader :monkeys

  def initialize(input)
    @monkeys =
      input.chomp.split(/\n\n/).map do |lines|
        _, item_line, op_line, test_line, true_line, false_line = lines.split(/\n/)

        items =
          item_line.match(/\s*Starting items: ([\d ,]+)/)[1].split(", ").map(&:to_i)
        operation =
          get_operation(op_line.match(/\s+Operation: new = old (\+|\*) (new|old|\d+)/))
        div_test =
          test_line.match(/\s+Test: divisible by (\d+)/)[1].to_i
        true_throw =
          true_line.match(/\s+If true: throw to monkey (\d+)/)[1].to_i
        false_throw =
          false_line.match(/\s+If false: throw to monkey (\d+)/)[1].to_i

        Monkey.new(items, operation, div_test, true_throw, false_throw)
      end
  end

  def get_operation(match_result)
    operator = match_result[1]
    operand = match_result[2]

    operand_is_number = /\d+/.match?(operand)

    case [operator, operand_is_number]
    when ["*", true]
      -> old { old * operand.to_i }
    when ["*", false]
      -> old { old * old}
    when ["+", true]
      -> old { old + operand.to_i }
    when ["+", false]
      -> old { old + old}
    end
  end

  def simulate(rounds = 20, worry_reducer = nil)
    (1..rounds).each do |round|
      @monkeys.each { |monkey| monkey.step(@monkeys, worry_reducer) }
    end

    self
  end
end

pp Monkeys.new(input).simulate.monkeys.max_by(2, &:inspection_count).map(&:inspection_count).reduce(&:*)

m = Monkeys.new(input)
reducer = m.monkeys.map(&:divisible_test).reduce(&:lcm)
reducer = m.monkeys.map(&:divisible_test).reduce(&:*)
pp m.simulate(10000, reducer).monkeys.max_by(2, &:inspection_count).map(&:inspection_count).reduce(&:*)

