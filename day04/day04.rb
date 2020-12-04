require 'benchmark'

lines = <<~MAP
  ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
  byr:1937 iyr:2017 cid:147 hgt:183cm

  iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
  hcl:#cfa07d byr:1929

  hcl:#ae17e1 iyr:2013
  eyr:2024
  ecl:brn pid:760753108 byr:1931
  hgt:179cm

  hcl:#cfa07d eyr:2025 pid:166559648
  iyr:2011 ecl:brn hgt:59in
MAP

# input = lines.split(/\n{2,}/).map {|line| line.split.map{|field| field.split(?:)}.to_h }
input =
  File
  .read('input.txt')
  .split(/\n{2,}/)
  .map { |line| line.split.map { |field| field.split(':') }.to_h }

REQUIRED_FIELDS = %w[byr iyr eyr hgt hcl ecl pid].freeze

FIELD_RULES = [
  ['byr', ->(v) { v.to_i.between?(1920, 2002) }],
  ['iyr', ->(v) { v.to_i.between?(2010, 2020) }],
  ['eyr', ->(v) { v.to_i.between?(2020, 2030) }],
  ['hgt', ->(v) { valid_height?(v) }],
  ['hcl', ->(v) { v.match(/#[0-9a-f]{6}/) }],
  ['ecl', ->(v) { %w[amb blu brn gry grn hzl oth].any? { |color| color == v } }],
  ['pid', ->(v) { v.match(/^[0-9]{9}$/) }]
]

def valid_height?(height)
  number = height[0...-2].to_i
  return number >= 59 && number <= 76 if height.end_with?('in')
  return number >= 150 && number <= 193 if height.end_with?('cm')

  false
end

def run(passports:)
  passports.count do |passport|
    valid?(passport: passport)
  end
end

def valid?(passport:)
  (REQUIRED_FIELDS.all? { |key| passport.key?(key) }) && (FIELD_RULES.all? { |(key, rule)| rule.call(passport[key]) })
end

puts run(passports: input)

# valids = 0

# Benchmark.bm do |x|
#   x.report do
#     valids = lines.count do |line|
#       PasswordPolicy.from_line(line).valid?
#     end
#   end
# end

# puts valids