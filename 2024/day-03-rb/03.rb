lines = ARGF.map(&:chomp)

a = lines.map do |line|
  line.chomp.scan(/mul\((\d{1,3}),(\d{1,3})\)/).map { |(a, b)| a.to_i * b.to_i }.sum
end.sum
puts a

run = true
b = lines.map do |line|
  line.chomp.scan(/(mul\((\d{1,3}),(\d{1,3})\))|(do\(\))|(don't?\(\))/).inject(0) do |acc, (_, a, b, _do, _dont)|
    case [a, _do, _dont]
    when [nil, nil, nil]
      acc
    when [nil, 'do()', nil]
      run = true
      acc
    when [nil, nil, 'don\'t()']
      run = false
      acc
    else
      run ? acc + a.to_i * b.to_i : acc
    end
  end
end.sum
puts b
