# frozen_string_literal: true

# This solution attempts to generate all possible strings
# It has a halting problem for the recursive cases (part 2) which is not solved
# I moved on to build a regex instead. See other.

# build_possible_strings
def build_possible_strings(rules, idx, lookup)
  return lookup[idx] unless lookup[idx].nil?

  if rules[idx].is_a? String
    lookup[idx] = [rules[idx]]
    return lookup[idx]
  end

  lookup[idx] = rules[idx].flat_map do |conjunction|
    search_results = conjunction.map { |term| build_possible_strings(rules, term, lookup) }
    search_results.first.product(*search_results[1..-1]).map { |result| result.join('') }
  end

  lookup[idx]
end

rule_data, message_data = File.read(ARGV[0]).chomp.split("\n\n")

rules = {}
rule_data.split("\n").each do |s|
  idx, premises = s.split(': ')

  rules[idx.to_i] =
    if premises =~ /"(a|b)"/
      $1
    else
      premises.split(' | ').map { |conjunction| conjunction.split(' ').map(&:to_i) }
    end
end

lookup = {}
build_possible_strings(rules, 0, lookup)

base_message_lookup = lookup[0].each_with_object({}) { |m, acc| acc[m] = true }

puts(message_data.split("\n").count { |msg| base_message_lookup[msg] })
