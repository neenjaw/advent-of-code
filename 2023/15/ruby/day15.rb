require 'set'

# rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7

def read
  parts = []
  ARGF.read.chomp.split(",").each do |line|
    part = line.chars
    parts << part
  end
  parts
end

# Start with zero
# iterate through each char of the string
# - determine ASCII value
# - increase the current value by the ASCII value
# - current *= 17
# - current %= 256

def hash(chars)
  chars.inject(0) do |current, char|
    current += char.ord
    current *= 17
    current %= 256
    current
  end
end

instructions = read

hash_sum = instructions.map { |part| hash(part) }.sum

pp hash_sum

# 256 boxes named 0->255
# arranged in sequence
# have spaces for lenses
# lenses have focal length 1->9

boxes = Array.new(256) { |i| { id: i, lenses: [] } }.to_h { |box| [box[:id], box] }

filled_boxes = instructions.inject(boxes) do |boxes, instruction|
  label = instruction.take_while { |char| char =~ /[a-z]/ }
  box_num = hash(label)
  box_action_serialized = instruction.drop_while { |char| char =~ /[a-z]/ }
  box_action = box_action_serialized.first == "-" ? :remove : :add
  lens = box_action == :add ? box_action_serialized.drop(1).join.to_i : nil

  # puts "#{label} #{box_num} #{box_action} #{lens}"

  if box_action == :add
    existing_lens = boxes[box_num][:lenses].find { |lens| lens[:label] == label }
    if existing_lens
      existing_lens[:focal_length] = lens
    else
      boxes[box_num][:lenses] << { label: label, focal_length: lens }
    end
  else # box_action == :remove
    boxes[box_num][:lenses] = boxes[box_num][:lenses].reject { |lens| lens[:label] == label }
  end

  boxes
end

focusing_power = filled_boxes.values
  .map do |box|
    box[:lenses].each_with_index.sum do |lens, index|
      (box[:id] + 1) * (index + 1) * lens[:focal_length]
    end
  end
  .sum

pp focusing_power
