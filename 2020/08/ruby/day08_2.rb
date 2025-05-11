PROGRAM = ARGF.readlines.map do |line|
  instruction, value = line.chomp.split
  value = value.to_i
  [instruction, value]
end.freeze

change_positions = PROGRAM.each.with_index.map do |(instruction, _value), i|
  i if %w[jmp nop].include?(instruction)
end.compact

END_OF_PROGRAM = PROGRAM.length

def run(invert_instruction_at)
  visited = []
  acc = 0
  pointer = 0
  while !visited[pointer] && pointer != END_OF_PROGRAM
    visited[pointer] = true
    instruction, value = PROGRAM[pointer]

    if pointer == invert_instruction_at
      case instruction
      when 'nop'
        instruction = 'jmp'
      when 'jmp'
        instruction = 'nop'
      end
    end

    case instruction
    when 'nop'
      pointer += 1
    when 'acc'
      acc += value
      pointer += 1
    when 'jmp'
      pointer += value
    else
      puts instruction, pointer, value, END_OF_PROGRAM
      raise ArgumentError, 'Unsupported instruction'
    end
  end

  reason = pointer == END_OF_PROGRAM ? :complete : :inf_loop

  [reason, acc]
end

_, acc = change_positions.map { |pos| run(pos) }.find { |reason, _acc| reason == :complete }

puts "Solution 2: #{acc}"
