# Advent of Code 2023, Day 3
#
# seeds: 79 14 55 13

# seed-to-soil map:
# 50 98 2
# 52 50 48

# soil-to-fertilizer map:
# 0 15 37
# 37 52 2
# 39 0 15

# fertilizer-to-water map:
# 49 53 8
# 0 11 42
# 42 0 7
# 57 7 4

# water-to-light map:
# 88 18 7
# 18 25 70

# light-to-temperature map:
# 45 77 23
# 81 45 19
# 68 64 13

# temperature-to-humidity map:
# 0 69 1
# 1 0 69

# humidity-to-location map:
# 60 56 37
# 56 93 4


# read example input from ARGF, first splitting by blank lines
seeds, input_maps = ARGF.read.split("\n\n", 2)
maps = input_maps.split("\n\n").map do |map|
  _title, mappings = map.split("\n", 2)
  mappings.split("\n").map do |mapping|
    destination, start, length = mapping.split.map(&:to_i)

    start_range = start..(start+length-1)
    destination_range = destination..(destination+length-1)

    {
      title: _title,
      mapping: mapping,
      destination: destination,
      start: start,
      length: length,
      start_range: start_range,
      destination_range: destination_range,
    }
  end
end

least = seeds.split.drop(1).map(&:to_i).map do |seed|
  maps.inject(seed) do |seed_value, map|
    next_seed_value = nil

    layer_enum = map.to_enum
    while next_seed_value.nil? and layer = layer_enum.next rescue nil
      if layer[:start_range].include?(seed_value)
        offset = seed_value - layer[:start]
        next_seed_value = layer[:destination] + offset
      end
    end

    next_seed_value || seed_value
  end
end.min

pp least

start_time = Time.now.to_f * 1_000_000

rleast = seeds.split
  .drop(1)
  .map(&:to_i)
  .each_slice(2)
  .map { |start, length| start..(start + length - 1) }
  .map do |seed_range|
    maps.inject([seed_range]) do |seed_ranges, map_group|

      map_group_result =
        map_group.inject([[], seed_ranges]) do |(mapped, unmapped), layer|

          next_unmapped = []

          unmapped.each do |unmapped_range|

            start_range = layer[:start_range]
            destination_range = layer[:destination_range]

            offset = destination_range.begin - start_range.begin

            if start_range.include?(unmapped_range.begin) && start_range.include?(unmapped_range.end)
              mapped << ((unmapped_range.begin + offset)..(unmapped_range.end + offset))
            elsif start_range.include?(unmapped_range.begin)
              mapped << ((unmapped_range.begin + offset)..(start_range.end + offset))
              next_unmapped << ((start_range.end+1)..unmapped_range.end)
            elsif start_range.include?(unmapped_range.end)
              mapped << ((start_range.begin + offset)..unmapped_range.end+offset)
              next_unmapped << (unmapped_range.begin..start_range.begin-1)
            elsif unmapped_range.include?(start_range.begin) && unmapped_range.include?(start_range.end)
              mapped << ((start_range.begin + offset)..(start_range.end + offset))
              next_unmapped << (unmapped_range.begin..start_range.begin-1)
              next_unmapped << ((start_range.end+1)..unmapped_range.end)
            else
              next_unmapped << unmapped_range
            end
          end

          [mapped, next_unmapped]
        end

      puts "After round #{map_group.first[:title]}: #{map_group_result.sum(&:size)}"

      map_group_result.flatten
    end
    .tap do |seed_ranges|
      compute_time = Time.now.to_f * 1_000_000 - start_time
      puts "Compute time: #{Time.at((compute_time) / 1_000_000).strftime("%M:%S.%L")}"
      puts "After round: #{seed_ranges.sum(&:size)} \n\n ------------------ \n\n"
    end
    .min_by(&:begin)
  end
  .min_by(&:begin)
  .begin

total_time = Time.now.to_f * 1_000_000 - start_time
puts "total time: #{Time.at(total_time / 1_000_000).strftime("%M:%S.%L")}"

pp rleast
