require "set"

files = [
  "example",
  "input"
]

DEBUG = ARGV.include?("--debug") || ARGV.include?("--debug-no-gets")
DEBUG_NO_GETS = ARGV.include?("--debug-no-gets")
file = ARGV.find { |arg| arg.start_with?("--source=") }.split("=").last
# part = ARGV.find { |arg| arg.start_with?("-p") }.split("p").last.to_i
ARGV.clear

puts "file: #{file}" if DEBUG

data = files.map do |file|
  [file, File.readlines(file).map(&:chomp).first]
end.to_h

disk_map = data[file]

puts "disk_map: #{disk_map}" if DEBUG

id = 0
expanded = disk_map.chars.each_with_index.map do |char, i|
  block_type = i % 2 == 0 ? :file : :space

  if block_type == :file
    current_id = id
    id += 1
    [:file, current_id, char.to_i]
  else
    [:space, nil, char.to_i]
  end
end

puts "expanded: #{expanded.inspect}" if DEBUG

def p1(drive_map)
  drive_map = drive_map.map(&:dup)
  disk = []

  while !drive_map.empty?
    block = drive_map.shift

    if block[0] == :file
      size = block[2]
      id = block[1]
      size.times { disk << id }
    elsif block[0] == :space
      size = block[2]

      to_fill = size
      back_node = nil
      while to_fill > 0
        back_node = drive_map.pop
        while back_node[0] == :space
          back_node = drive_map.pop
        end

        back_node_size = back_node[2]
        back_node_id = back_node[1]

        fill = [to_fill, back_node_size].min
        to_fill -= fill
        fill.times { disk << back_node_id }
        back_node[2] -= fill
        if back_node[2] > 0
          drive_map << back_node
        end
      end
    else
      raise "Unknown block type: #{block[0]}"
    end
  end

  disk
end

drive = p1(expanded)
puts "p1: #{drive.inspect}" if DEBUG
ans = drive.each_with_index.sum { |id, i| id * i }
puts "p1: #{ans}"

def p2(drive_map)
  drive_map = drive_map.map(&:dup)
  disk = []

  file_list = drive_map
    .select { |block| block[0] == :file }
    .sort_by { |block| block[1] }
    .reverse
  puts "disk_segment_map: #{file_list.inspect}" if DEBUG
  moved_blocks = Set.new

  while !drive_map.empty?
    block = drive_map.shift

    if block[0] == :file
      size = block[2]
      id = block[1]
      if moved_blocks.include?(id)
        drive_map.unshift([:space, nil, size])
        next
      end
      moved_blocks << id
      size.times { disk << id }
    elsif block[0] == :space
      size = block[2]
      to_fill = size

      while to_fill > 0
        found_segment = file_list.find { |block| block[2] <= to_fill && !moved_blocks.include?(block[1]) }

        if found_segment
          segment_id = found_segment[1]
          segment_size = found_segment[2]
          moved_blocks << segment_id

          to_fill -= segment_size
          segment_size.times { disk << segment_id }
        else
          to_fill.times { disk << 0 }
          to_fill = 0
        end
      end

    else
      raise "Unknown block type: #{block[0]}"
    end
  end

  disk
end

drive = p2(expanded)
puts "p2: #{drive.inspect}" if DEBUG
ans = drive.each_with_index.sum { |id, i| id * i }
puts "p2: #{ans}"
