reports = []

ARGF.each do |line|
  numbers = line.chomp.split(/\s+/).map(&:to_i)
  reports << numbers
end

DEBUG = false

def is_report_safe(report, dampened = false)
  direction = nil
  fail_at = nil
  result = report.each_with_index.all? do |num, i|
    fail_at = i
    next true if i == 0
    last = report[i - 1]

    puts "Checking #{last} -> #{num}" if DEBUG

    if direction.nil?
      direction = num > last ? :up : :down
    end

    diff = num - last
    if direction == :up && diff < 0
      puts "Direction is up and #{num} < #{last}" if DEBUG
      next false
    elsif direction == :down && diff > 0
      puts "Direction is down and #{num} > #{last}" if DEBUG
      next false
    else
      puts "Diff is #{diff}" if DEBUG
      diff.abs >= 1 && diff.abs <= 3
    end
  end

  return result if dampened || result

  if !result
    puts "Dampening" if DEBUG
    (0...(report.length)).to_a.any? do |i|
      puts i.inspect if DEBUG
      next if report[i].nil?
      dampened_report = report.dup
      dampened_report.delete_at(i)
      r = is_report_safe(dampened_report, true)
      puts "Dampened report is safe with #{i} removed when #{fail_at}, delta #{fail_at - i}" if r && DEBUG
      r
    end
  end
end

x = reports.count do |report|
  is_report_safe(report)
end

puts x
