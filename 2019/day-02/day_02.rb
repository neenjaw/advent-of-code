def run_intcode_program(program)
  position = 0

  loop do
    opcode = program[position]

    case opcode
    when 1
      # Addition
      input1 = program[program[position + 1]]
      input2 = program[program[position + 2]]
      output_position = program[position + 3]
      program[output_position] = input1 + input2
    when 2
      # Multiplication
      input1 = program[program[position + 1]]
      input2 = program[program[position + 2]]
      output_position = program[position + 3]
      program[output_position] = input1 * input2
    when 99
      # Halt
      break
    else
      # Unknown opcode
      raise "Unknown opcode: #{opcode}"
    end

    position += 4
  end

  program[0] # Return the value at index 0
end
if $PROGRAM_NAME == __FILE__
program = [1,9,10,3,2,3,11,0,99,30,40,50]
result = run_intcode_program(program)
puts result.inspect
end
