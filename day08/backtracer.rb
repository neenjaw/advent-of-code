PROGRAM = ARGF.readlines.map do |line|
  instruction, value = line.chomp.split
  value = value.to_i
  [instruction, value]
end.freeze

change_positions = PROGRAM.each.with_index.map do |(instruction, _value), i|
  i if %w[jmp nop].include?(instruction)
end.compact

puts change_positions.inspect

END_OF_PROGRAM = PROGRAM.length

def make_state
  { position: 0, acc: 0, visited: []}
end

def clone_state(state)
  { position: state[:position], acc: state[:acc], visited: state[:visited].clone}
end

state = make_state
history = []
success = false
while !change_positions.empty? && !success
  flip_at = change_positions.shift

  while state[:position] != END_OF_PROGRAM

    instruction, value = PROGRAM[state[:position]]

    history << clone_state(state) if %w[jmp nop].include?(instruction) && history.empty?

    if state[:position] == flip_at
      case instruction
      when 'nop'
        instruction = 'jmp'
      when 'jmp'
        instruction = 'nop'
      end
    end

    next_position = state[:position]
    case instruction
    when 'nop'
      next_position += 1
    when 'acc'
      state[:acc] += value
      next_position += 1
    when 'jmp'
      next_position += value
    else
      puts instruction, next_position, value, END_OF_PROGRAM
      raise ArgumentError, 'Unsupported instruction'
    end

    state[:visited][state[:position]] = true

    if state[:visited][next_position]
      unless history.empty?
        state = history.pop
      end
      break
    end

    state[:position] = next_position
  end

  if state[:position] == END_OF_PROGRAM
    success = true
  end
end

if success
  puts "Success when flipping at position #{flip_at}"
  puts "Acc: #{state[:acc]}"
else
  puts 'No solution'
end
