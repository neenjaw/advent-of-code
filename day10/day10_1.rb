adapters = ARGF.readlines.map { |line| line.chomp.to_i }.sort

last = 0
diff1 = 0
diff3 = 0
until adapters.empty?
  adapter = adapters.shift

  diff1 += 1 if adapter - last == 1
  diff3 += 1 if adapter - last == 3

  last = adapter
end

device = last + 3
diff1 += 1 if device - last == 1
diff3 += 1 if device - last == 3

p diff1
p diff3
puts diff1 * diff3
