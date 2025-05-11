# A game of cups
class CupGame
  attr_reader :cups

  def initialize(cups)
    @cups = [*cups]
  end

  def play(moves)
    move = 0
    moves.times do
      move += 1
      current_cup = cups.shift
      picked_up_cups = cups.shift(3)
      cups.unshift(current_cup)

      destination_cup = current_cup - 1
      destination_cup_index = nil
      while destination_cup_index.nil?
        destination_cup_index = cups.find_index(destination_cup)

        if destination_cup_index.nil?
          destination_cup = destination_cup <= 1 ? 9 : destination_cup - 1
        end
      end

      cups.insert(destination_cup_index + 1, *picked_up_cups)
      cups.rotate!
    end

    cups.rotate! until cups.first == 1

    [*cups]
  end
end

class CrabCupGame
  attr_reader :cups, :lookup
  attr_accessor :current

  MAX = 1_000_000

  def initialize(cups)
    @cups = cups

    # Populate lookup with cup labels
    @lookup = cups.each_with_object({}).with_index do |(v, memo), idx|
      memo[v] = cups[idx + 1]
    end

    lookup[cups.last] = cups.max + 1

    # Populate lookup with remaining up to MAX
    ((cups.max + 1)..MAX).each do |v|
      lookup[v] = v + 1
    end

    lookup[MAX] = cups.first
  end

  def play(moves)
    current_cup = cups.first
    moves.times do
      picked_up_cup = lookup[current_cup]
      lookup[current_cup] = look_ahead(current_cup, 4)

      destination_cup = current_cup - 1
      while picked_up_contains?(picked_up_cup, destination_cup) || destination_cup < 1
        destination_cup -= 1 if picked_up_contains?(picked_up_cup, destination_cup)
        destination_cup = MAX if destination_cup < 1
      end

      destination_cup_next = lookup[destination_cup]
      lookup[destination_cup] = picked_up_cup
      lookup[look_ahead(picked_up_cup, 2)] = destination_cup_next

      current_cup = lookup[current_cup]
    end

    [lookup[1], lookup[lookup[1]]]
  end

  def picked_up_contains?(picked_up_cup, destination_cup)
    [picked_up_cup, lookup[picked_up_cup], lookup[lookup[picked_up_cup]]].include?(destination_cup)
  end

  def look_ahead(value, count)
    case count
    when 0
      value
    else
      look_ahead(lookup[value], count - 1)
    end
  end
end

cups = File.read(ARGV[0]).chomp.chars.map(&:to_i)

puts CupGame.new(cups).play(100).drop(1).join('')
puts CrabCupGame.new(cups).play(10_000_000).reduce(&:*)
