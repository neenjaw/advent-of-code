class MemoryNumber
  attr_reader :number, :last_turn, :before_last_turn

  def initialize(number, turn_seen)
    @number = number
    @last_turn = turn_seen
    @before_last_turn = nil
  end

  def saw_again(turn)
    @before_last_turn = last_turn
    @last_turn = turn
  end

  def times_seen
    [last_turn, before_last_turn].compact.count
  end
end

starting_numbers = ARGF.readlines.first.chomp.split(',').map(&:to_i)
starting_turn = starting_numbers.count + 1
ending_turn = 30_000_000

number_memory = {}
turn_memory = {}
starting_numbers.each.with_index(1) do |number, turn|
  number_memory[number] = MemoryNumber.new(number, turn)
  turn_memory[turn] = number
end

turn = starting_turn
loop do
  last_turn = turn - 1
  last_number = turn_memory[last_turn]

  if number_memory[last_number].times_seen == 1
    current_number = 0
  else
    turn_seen_before_last = number_memory[last_number].before_last_turn
    last_turn_seen = number_memory[last_number].last_turn
    current_number = last_turn_seen - turn_seen_before_last
  end

  if number_memory[current_number]
    number_memory[current_number].saw_again(turn)
  else
    number_memory[current_number] = MemoryNumber.new(current_number, turn)
  end

  turn_memory[turn] = current_number

  break if turn == ending_turn

  if (turn % 1_000_000 == 0)
    puts turn
  end

  turn += 1
end

puts turn_memory[turn]

# puts starting_numbers
# puts turn_memory[2020]
# puts turn_memory[ending_turn]
