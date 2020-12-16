require 'set'

class TicketField
  attr_reader :name, :lower_range, :upper_range

  def initialize(name, lower_range, upper_range)
    @name = name
    @lower_range = lower_range
    @upper_range = upper_range
  end

  def include?(number)
    lower_range.include?(number) || upper_range.include?(number)
  end
end

class Ticket
  attr_reader :numbers

  def initialize(numbers)
    @numbers = numbers.clone.freeze
  end
end

# Parse the input file
text = File.read(ARGV[0]).chomp

notes, my_ticket, nearby_tickets = text.split("\n\n")

notes = notes.split("\n").map do |note|
  note =~ /^([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)$/
  name = $1
  lower_range = ($2.to_i)..($3.to_i)
  upper_range = ($4.to_i)..($5.to_i)
  TicketField.new(name, lower_range, upper_range)
end

my_ticket = my_ticket.split("\n").last.split(',').map(&:to_i)

nearby_tickets = nearby_tickets.split("\n").drop(1)

# Part 1 - find the sum of all the invalid numbers

all_nearby_numbers = nearby_tickets.flat_map { |line| line.split(',') }.map(&:to_i)
all_nearby_invalid = all_nearby_numbers.reject { |number| notes.any? { |note| note.include?(number) } }
all_invalid_sum  = all_nearby_invalid.sum

puts "Part 1: #{all_invalid_sum}"

# part 2

nearby_tickets = nearby_tickets.map do |ticket_line|
  Ticket.new(ticket_line.split(',').map(&:to_i))
end

nearby_valid_tickets = nearby_tickets.select do |ticket|
  ticket.numbers.all? { |number| notes.any? { |note| note.include?(number) } }
end

nearby_valid_tickets << Ticket.new(my_ticket)

name_possibilities = notes.each_with_object([]) do |note, acc|
  (0...(notes.count)).each do |i|
    acc[i] ||= Set.new

    if nearby_valid_tickets.all? { |t| note.include?(t.numbers[i]) }
      acc[i].add(note.name)
    end
  end
end

column_names =
  name_possibilities
    .each.with_index
    .sort_by { |p, _i| p.size }
    .tap do |sorted|
      sorted.each.with_index do |(possibilities, place), i|
        if possibilities.size == 1
          sorted[i + 1..].each.with_index(i+1) do |(p, p_place), j|
            sorted[j] = [p - possibilities, p_place]
          end
        end
      end
    end
    .sort_by { |_p, i| i }
    .map { |p, _i| p.to_a.first }

departure_product =
  column_names
    .zip(my_ticket)
    .filter { |(name, n)| name.start_with?("depart")}
    .map { |(_, n)| n }
    .reduce(&:*)

puts "Part 2: #{departure_product}"