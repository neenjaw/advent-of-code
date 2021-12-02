program = ARGF.readlines.map do |line|
  instruction, value = line.chomp.split
  value = value.to_i
  [instruction, value]
end

visited = []
acc = 0
pointer = 0
while !visited[pointer]
  visited[pointer] = true
  instruction, value = program[pointer]

  case instruction
  when "nop"
    pointer += 1
  when "acc"
    acc += value
    pointer += 1
  when "jmp"
    pointer += value
  else
    raise ArgumentError, "Unsupported instruction"
  end
end

puts "Solution 1: #{acc}"
