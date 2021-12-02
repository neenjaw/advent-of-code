DIVIDER = 20_201_227

def transform(subject_number, loop_size)
  value = 1
  loop_size.times do
    value *= subject_number
    value %= DIVIDER
  end
  value
end

def loop_sequence(subject_number, key)
  Enumerator.new do |y|
    value = 1
    loop_number = 0

    until value == key
      loop_number += 1
      value *= subject_number
      value %= DIVIDER
      y << [loop_number, value]
    end
  end
end

def find_loop_size(public_key, subject_number = 7, max_loop_size = 10_000)
  loop_size, = loop_sequence(subject_number,  public_key).to_a.last
  loop_size
end

secret_a, secret_b = File.read(ARGV[0]).chomp.split("\n").map(&:to_i)

loop_size_a = find_loop_size(secret_a)
loop_size_b = find_loop_size(secret_b)

pp loop_size_a
pp loop_size_b

pp transform(secret_b, loop_size_a)
pp transform(secret_a, loop_size_b)
