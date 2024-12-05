require "set"

files = [
  "example",
  "input"
]

data = files.map do |file|
  upper, lower = File.read(file).split("\n\n")
  [
    file,
    [
      upper.split("\n"),
      lower.split("\n")
    ]
  ]
end.to_h

rules = data.map do |file, (upper, lower)|
  file_rules = {}
  upper.each do |line|
    l, r = line.split("|")
    file_rules[r] ||= Set.new
    file_rules[r] << l
  end

  [file, file_rules]
end.to_h

productions = data.map do |file, (upper, lower)|
  productions = lower.map do |line|
    pages = line.split(",")

    raise "even pages" if pages.size % 2 == 0

    middle_page = pages[pages.size / 2]
    pageset = Set.new(pages)

    { :middle_page => middle_page, :pageset => pageset, :pages => pages }
  end


  [file, productions]
end.to_h

# puts rules['example']
# puts productions['example']

version = 'input'
ruleset = rules[version]
correct, incorrect = productions[version].partition do |production|
  seen = Set.new
  pages = production[:pages]
  pageset = production[:pageset]

  pages.each do |page|
    page_rules = ruleset[page] || Set.new
    relevant_page_rules = page_rules & pageset

    if (relevant_page_rules.subtract(seen)).size > 0
      break nil
    end
    seen << page
  end
end

p1 = correct.sum { |production| production[:middle_page].to_i }

p2 = incorrect.sum do |production|
  order = []

  page_queue = production[:pages]
  pageset = production[:pageset]
  seen = Set.new

  while page_queue.size > 0
    page = page_queue.shift
    page_rules = ruleset[page] || Set.new
    relevant_page_rules = page_rules & pageset

    if (relevant_page_rules.subtract(seen)).size > 0
      page_queue.push(page)
      next
    end

    order << page
    seen << page
  end

  order[order.size / 2].to_i
end

puts p1
puts p2
