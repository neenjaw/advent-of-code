require 'set'
require 'io/console'

START = 'in'.freeze
ACCEPTED = 'A'.freeze
REJECTED = 'R'.freeze

def read
  workflows = {}
  part_ratings = []
  ws, ps = ARGF.read.chomp.split("\n\n")

  ws.split("\n").each do |line|
    parts = line.split(/[}{,]/)
    name = parts.first
    otherwise = parts.last
    rules = parts[1..-2].map do |rule_input|
      part_symbol = rule_input[0].to_sym
      comparison = rule_input[1] == "<" ? :< : :>
      rating, goto = rule_input[2..].split(":")
      { part: part_symbol, comparison: comparison, rating: rating.to_i, goto: goto}
    end

    workflows[name] = { rules: rules, otherwise: otherwise }
  end

  ps.split("\n").each do |line|
    line = line.gsub(/=/, ':')
    part_rating = eval(line)

    part_ratings << part_rating
  end

  [workflows, part_ratings]
end

workflows, part_ratings = read

# pp workflows
# pp part_ratings

def run_workflows(workflows, part_rating)
  state = START

  while state != ACCEPTED && state != REJECTED
    workflow = workflows[state]
    rules = workflow[:rules]

    matching_rule = rules.find do |rule|
      part_rating[rule[:part]].send(rule[:comparison], rule[:rating])
    end

    if matching_rule
      state = matching_rule[:goto]
    else
      state = workflow[:otherwise]
    end
  end

  state
end

def split_range(range, comparison, rating)
  # While it might be necessary to handle the case where the range is outside the
  # rating, it is not necessary for my input.

  # if comparison == :< && range.max < rating
  #   return {accepted: range, rejected: nil}
  # elsif comparison == :> && range.min > rating
  #   return {accepted: range, rejected: nil}
  # else
    if comparison == :<
      return {accepted: range.min..(rating-1), rejected: rating..range.max}
    else
      return {accepted: (rating+1)..range.max, rejected: range.min..rating}
    end
  # end
end

def run_range_workflow(workflows:, part_range_rating:)
  accepted_parts = []
  queue = [[START, part_range_rating]]

  while !queue.empty?
    state, range_rating = queue.shift

    if state == ACCEPTED
      accepted_parts << range_rating
      next
    elsif state == REJECTED
      next
    end

    workflow = workflows[state]
    rules = workflow[:rules]

    rules.each do |rule|
      symbol = rule[:part]
      comparison = rule[:comparison]
      rating = rule[:rating]

      split = split_range(range_rating[symbol], comparison, rating)
      accepted_range, rejected_range = split[:accepted], split[:rejected]

      accepted_part_range_rating = range_rating.dup
      accepted_part_range_rating[symbol] = accepted_range
      queue << [rule[:goto], accepted_part_range_rating]

      range_rating[symbol] = rejected_range
    end

    queue << [workflow[:otherwise], range_rating]
  end

  accepted_parts
end

results = part_ratings
  .map do |part_rating|
    part_rating[:sum] = part_rating.values.sum
    part_rating[:result] = run_workflows(workflows, part_rating)
    part_rating
  end
  .sum do |part_rating|
    part_rating[:result] == ACCEPTED ? part_rating[:sum] : 0
  end

pp results

range_results = run_range_workflow(
  workflows: workflows,
  part_range_rating: {x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000}
)
.map { |rating| %i[x m a s].map { |s| rating[s].size }.inject(:*) }
.inject(:+)

pp range_results
