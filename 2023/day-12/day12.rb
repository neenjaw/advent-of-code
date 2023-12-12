require 'set'

def dfs(memo, rule, clues, rule_index, clue_index, weight)
  # Do we have the solution already?
  return memo[[rule_index, clue_index, weight]] if memo.key?([rule_index, clue_index, weight])

  # Are we at the base case?
  if rule_index == rule.length
    all_clues_used = clue_index == clues.length && weight.zero?
    last_char_completes_clue = clue_index == clues.length - 1 && weight == clues[clue_index]

    if (all_clues_used || last_char_completes_clue)
      return 1
    else
      return 0
    end
  end

  step_total = 0
  char = rule[rule_index]

  # need to get to our base case to progressively build up our answer
  # so as we walk through the rule, we need to consider the case where
  # 1. the current rule character is a dot or unknown
  # 2. the current rule character is a hash or unknown
  # validating the state against that choice, and then recursing to the next
  # character in the rule to then consider the validity of the next choices

  # consider the case where the current rule character is a dot or unknown
  is_dot_or_unknown = char == '.' || char == '?'

  if is_dot_or_unknown
    if weight.zero?
      step_total += dfs(memo, rule, clues, rule_index + 1, clue_index, 0)
    elsif clues[clue_index] == weight
      step_total += dfs(memo, rule, clues, rule_index + 1, clue_index + 1, 0)
    end
  end

  # consider the case where the current rule character is a hash or unknown
  is_hash_or_unknown = char == '#' || char == '?'
  is_before_the_last_clue = clue_index < clues.length
  is_clue_still_possible = is_before_the_last_clue && weight < (clues[clue_index])

  if is_hash_or_unknown && is_clue_still_possible
    step_total += dfs(memo, rule, clues, rule_index + 1, clue_index, weight + 1)
  end

  # Remember the solution for this subproblem
  memo[[rule_index, clue_index, weight]] = step_total

  step_total
end

def read
  lines = []
  ARGF.each_line do |line|
    rule, clues = line.split
    clues = clues.split(",").map(&:to_i)
    lines << [rule, clues]
  end
  lines
end

def part1(rules)
  rules.inject(0) do |total, (rule, clues)|
    total += dfs({}, rule, clues, 0, 0, 0)

    total
  end
end

def part2(rules)
  rules.inject(0) do |total, (rule, clues)|
    rule, clues = ("#{rule}?" * 5).delete_suffix('?').chars, clues * 5
    total += dfs({}, rule, clues, 0, 0, 0)

    total
  end
end

rules = read
puts part1(rules)
puts part2(rules)
