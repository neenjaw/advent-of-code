require 'set'

class TicketCategory
  attr_reader :name, :lower_range, :upper_range

  def initialize(name, lower_range, upper_range)
    @name = name
    @lower_range = lower_range
    @upper_range = upper_range
  end

  def include?(number)
    lower_range.include?(number) || upper_range.include?(number)
  end

  def self.new_from_note(note)
    note =~ /^([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)$/
    name = $1
    lower_range = ($2.to_i)..($3.to_i)
    upper_range = ($4.to_i)..($5.to_i)
    TicketCategory.new(name, lower_range, upper_range)
  end
end

def notes_to_categories(notes)
  notes.split("\n").map do |note|
    TicketCategory.new_from_note(note)
  end
end

def ticket_data_to_ticket(data)
  data.split(',').map(&:to_i).freeze
end

# Parse the input file
notes, my_ticket_data, nearby_ticket_data = File.read(ARGV[0]).chomp.split("\n\n")
categories = notes_to_categories(notes)
nearby_tickets = nearby_ticket_data.split("\n").drop(1)

# Part 1 - find the sum of all the invalid numbers

all_nearby_numbers = nearby_tickets.flat_map { |line| line.split(',') }.map(&:to_i)
all_nearby_invalid = all_nearby_numbers.reject { |number| categories.any? { |category| category.include?(number) } }
all_invalid_sum = all_nearby_invalid.sum

puts "Part 1: #{all_invalid_sum}"

# part 2

nearby_tickets = nearby_tickets.map { |ticket_data| ticket_data_to_ticket(ticket_data) }
my_ticket = my_ticket_data.split("\n").last.then { |data| ticket_data_to_ticket(data) }

nearby_valid_tickets = nearby_tickets.select do |ticket|
  ticket.all? { |number| categories.any? { |category| category.include?(number) } }
end

nearby_valid_tickets << my_ticket

name_possibilities = categories.each_with_object([]) do |category, acc|
  (0...(categories.count)).each do |i|
    if nearby_valid_tickets.all? { |t| category.include?(t[i]) }
      acc[i] ||= Set.new
      acc[i].add(category.name)
    end
  end
end

column_names =
  name_possibilities
  .each.with_index
  .sort_by { |p, _i| p.size }
  .tap do |sorted|
    # sorted contains an array of tuples, [Set[], position]
    # The set is the set of possible names, the position is the original
    # position on the ticket where the name appears.

    # Due to the nature of the problem, one ticket column field has one possibility,
    # the next has 2, increasing with each column up to n possibilities. So we sorted
    # the possibilities by number of possibilities to progressive perform a set difference
    sorted.each.with_index do |(possibilities, _place), i|
      # for each set of possibilities forward, remove the current possibility
      next_i = i + 1
      sorted[next_i..].each.with_index(next_i) do |(p, _p_place), j|
        sorted[j][0] = p - possibilities
      end
    end
  end
  .sort_by(&:last)
  .map { |p, _i| p.to_a.first }

departure_product =
  column_names
  .zip(my_ticket)
  .filter { |(name, _n)| name.start_with?("depart") }
  .map(&:last)
  .reduce(&:*)

puts "Part 2: #{departure_product}"