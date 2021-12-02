def handle_mask(mask_instructions)
  mask_pattern = mask_instructions.chomp.partition(' = ').last

  overwrite_mask = mask_pattern.tr('X10', '100').to_i(2)
  write_mask = mask_pattern.tr('X', '0').to_i(2)

  [overwrite_mask, write_mask]
end

def handle_mem(mem, mem_instruction, overwrite_mask, write_mask)
  mem_instruction.chomp =~ /mem\[(\d+)\] = (\d+)/
  addr = $1.to_i
  value = $2.to_i
  value &= overwrite_mask
  value |= write_mask

  mem[addr] = value
end

acc = { mem: {}, overwrite_mask: nil, write_mask: nil }
ARGF.readlines.each_with_object(acc) do |line, acc|
  acc[:overwrite_mask], acc[:write_mask] = handle_mask(line) if line.start_with?('mask')
  handle_mem(acc[:mem], line, acc[:overwrite_mask], acc[:write_mask]) if line.start_with?('mem')
end

# acc[:mem].keys.sort.each { |key| puts "#{key}: #{acc[:mem][key]}" }
puts acc[:mem].values.sum
