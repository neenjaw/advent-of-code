adapters = ARGF.readlines.map { |line| line.chomp.to_i }.sort
adapters.unshift(0)
adapters.push(adapters.last + 3)
adapters = adapters.each.with_index.to_a

def traverse(adapters, current_idx, table)
  # BASE CASE
  if current_idx == adapters.count - 1
    return table[current_idx] = 1
  end

  current = adapters[current_idx][0]
  to_search = adapters[current_idx+1..].take_while { |(adapter, idx)| adapter - 3 <= current }

  table[current_idx] = to_search.sum do |(adapter, idx)|
    table[idx] ? table[idx] : traverse(adapters, idx, table)
  end
end

p "Solution: #{traverse(adapters, 0, {})}"