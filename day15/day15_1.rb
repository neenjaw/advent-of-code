class MemoryNumber
  attr_reader :number, :turns_seen

  def initialize(number, turn_seen)
    @number = number
    @turns_seen = [turn_seen]
  end

  def saw_again(turn)
    turns_seen << turn
  end

  def times_seen
    turns_seen.count
  end
end

starting_numbers = ARGF.readlines.first.chomp.split(',').map(&:to_i)
starting_turn = starting_numbers.count + 1
ending_turn = 30_000_000

number_memory = {}
turn_memory = [:start]
starting_numbers.each.with_index(1) do |number, turn|
  number_memory[number] = MemoryNumber.new(number, turn)
  turn_memory << number
end

turn = starting_turn
loop do
  last_turn = turn - 1
  last_number = turn_memory[last_turn]

  if number_memory[last_number].times_seen == 1
    current_number = 0
  else
    turn_seen_before_last, last_turn  = number_memory[last_number].turns_seen.last(2)
    current_number = last_turn - turn_seen_before_last
  end

  if number_memory[current_number]
    number_memory[current_number].saw_again(turn)
  else
    number_memory[current_number] = MemoryNumber.new(current_number, turn)
  end

  turn_memory << current_number

  break if turn == ending_turn

  turn += 1
end

# puts starting_numbers
puts turn_memory[ending_turn]
