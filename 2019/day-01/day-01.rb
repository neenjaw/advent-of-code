
def total_fuel_required(numbers)
  numbers.sum { |x| (x / 3).floor - 2 }
end

if $PROGRAM_NAME == __FILE__
  total = 0

  ARGF.each_line do |line|
    number = line.to_i
    result = total_fuel_required([number])
    total += result

    while result.positive?
      result = total_fuel_required([result])
      total += result if result.positive?
    end
  end

  puts total
end
