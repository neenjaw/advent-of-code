require 'set'
require 'z3'

class Solution
  attr_reader :input_data, :lines, :machines

  def initialize(input_data)
    @input_data = input_data
    @lines = input_data.chomp.split("\n")
    @machines = parse_machines
  end

  def part1
    machines.map do |machine|
      visited = Set.new()

      queue = [[0, machine.diagram.dup]]

      while queue.any?
        current = queue.shift
        visited << current[1]

        break current if current[1].configured?

        machine.buttons.each do |button|
          next_diagram = current[1].apply(button)

          next if visited.include?(next_diagram)

          queue << [current[0] + 1, next_diagram]
        end
      end
    end
    .sum { it[0] }
  end

  def part2
    total_min_presses = 0

    input_data.strip.each_line do |line|
      next if line.strip.empty?

      # 1. Parse the input line
      # Matches the buttons in ( ) and the requirements in { }
      button_data = line.scan(/\(([\d,]+)\)/).flatten
      target_data = line.scan(/\{([\d,]+)\}/).flatten.first

      buttons = button_data.map { |b| b.split(',').map(&:to_i) }
      targets = target_data.split(',').map(&:to_i)

      # 2. Initialize Z3 Optimizer
      optimizer = Z3::Optimize.new

      # Create variables for each button (how many times it is pressed)
      # x0, x1, x2... must be non-negative integers
      press_counts = buttons.length.times.map { |i| Z3.Int("x#{i}") }
      press_counts.each { |var| optimizer.assert(var >= 0) }

      # 3. Define Constraints
      # For each counter, the sum of presses affecting it must equal the target
      targets.each_with_index do |target_value, counter_idx|
        relevant_buttons_sum = 0
        buttons.each_with_index do |affected_counters, button_idx|
          if affected_counters.include?(counter_idx)
            relevant_buttons_sum += press_counts[button_idx]
          end
        end
        optimizer.assert(relevant_buttons_sum == target_value)
      end

      # 4. Define Objective: Minimize the sum of all button presses
      total_presses_expr = press_counts.inject(:+)
      optimizer.minimize(total_presses_expr)

      # 5. Solve
      if optimizer.satisfiable?
        model = optimizer.model
        # In the Ruby z3 gem, you access the value by passing the expression to the model object
        min_for_this_machine = model[total_presses_expr].to_i

        total_min_presses += min_for_this_machine
      else
        raise "Machine Unsolvable!"
      end
    end

    total_min_presses
  end

  def parse_machines
    @lines.map { Machine.parse(it) }
  end

  class Machine
    attr_reader :diagram, :buttons, :requirements

    def initialize(diagram, buttons, requirements)
      @diagram, @buttons, @requirements = diagram, buttons, requirements
      @press_count = 0
    end

    def self.parse(line)
      d = nil
      b = []
      r = nil

      line.split(" ")
        .each do |part|
          case part
          when /^\[/
            d = Diagram.parse(part)
          when /^\(/
            b << Button.parse(d, part)
          when /^\{/
            r = Requirements.parse(part)
          else
            raise "unexpected part"
          end
        end

      self.new(d, b, r)
    end
  end

  class Diagram
    ON = "#"
    OFF = "."

    attr_reader :goal, :current, :picture

    def initialize(picture, goal, current)
      @picture = picture
      @goal = goal
      @current = current
    end

    def self.parse(str)
      raise "not a light diagram" if !str.start_with?("[")

      goal_mask = 0
      picture = str.delete("[]")
      picture.chars.each_with_index do |char, i|
        goal_mask |= (1 << i) if char == ON
      end

      self.new(picture, goal_mask, 0)
    end

    def apply(button)
      result = current ^ button.wiring
      self.class.new(picture, goal, result)
    end

    def configured?
      goal == current
    end

    def hash
      [@goal, @current].hash
    end

    def eql?(other)
      return false unless other.is_a?(Diagram)
      goal == other.goal && current == other.current
    end
  end

  class Button
    attr_reader :wiring, :input

    def initialize(input, *wires)
      @input = input
      @wiring = 0
      wires.each { |wire| @wiring |= (1 << wire) }
      @picture = wiring.to_s(2).tr('01', '.#')
    end

    def self.parse(diagram, str)
      raise "not a button" if !str.start_with?("(")

      input = str.delete("()")
      indicators = input.split(",").map { it.to_i }

      self.new(input, *indicators)
    end
  end

  class Requirements
    attr_reader :values

    def initialize(*values)
      @values = values
    end

    def self.parse(str)
      raise "not a button" if !str.start_with?("{")

      values = str.delete("{}").split(",").map { it.to_i }

      self.new(*values)
    end
  end
end
