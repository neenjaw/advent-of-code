require 'set'

ingredients, possible_allergens = File.read(ARGV[0]).chomp.split("\n").each_with_object([Hash.new(0), {}]) do |line, (ingredients, possible_allergens)|
  line =~ /(.+) \(contains (.+)\)/
  food_ingredients = $1.split(' ')
  allergens = $2.split(', ')

  # count the occupance of each ingredient
  food_ingredients.each { |ingredient| ingredients[ingredient] += 1 }

  allergens.each do |allergen|
    allergen_set = food_ingredients.to_set
    possible_allergens[allergen] ||= allergen_set
    possible_allergens[allergen] &= allergen_set
  end
end

allergens = possible_allergens.values.reduce(&:|).to_a
sum = allergens.each_with_object(ingredients) { |allergen, memo| memo.delete(allergen) }.values.sum

pp sum

certain_allergens = {}
until possible_allergens.empty?
  allergy, ingredients = possible_allergens.min_by { |_, v| v.size }
  certain_allergens[allergy] = ingredients.to_a.first
  possible_allergens.delete(allergy)
  possible_allergens.keys { |k| possible_allergens[k] -= ingredients }
end

answer = certain_allergens
         .sort_by(&:first)
         .map(&:last)
         .join(',')

pp answer
