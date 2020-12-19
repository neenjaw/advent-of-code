# frozen_string_literal: true

RECURSIVE_RULE_LIMIT = 15

def build(rules, key = 0, eights = 0, elevens = 0)
  return rules[key] if rules[key].is_a? String

  left, right =
    rules[key]
    .map do |conjunction|
      conjunction
        .map do |term|
          next '' if term == 8 && eights > RECURSIVE_RULE_LIMIT
          next '' if term == 11 && elevens > RECURSIVE_RULE_LIMIT

          next_eights = term == 8 ? eights + 1 : eights
          next_elevens = term == 11 ? elevens + 1 : elevens
          build(rules, term, next_eights, next_elevens)
        end
        .join('')
    end

  right ? "(?:(?:#{left})|(?:#{right}))" : left
end

rule_data, message_data = File.read(ARGV[0]).chomp.split("\n\n")

rules = {}
rule_data.split("\n").each do |s|
  idx, premises = s.split(': ')

  rules[idx.to_i] =
    if premises.start_with?('"')
      premises[1]
    else
      premises.split(' | ').map { |conjunction| conjunction.split(' ').map(&:to_i) }
    end
end

zero_rule_regex = Regexp.new("^#{build(rules)}$")
puts _matching_count = message_data.split("\n").count { |msg| zero_rule_regex.match?(msg) }
