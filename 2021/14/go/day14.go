package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"log"
	"math"
	"strings"
)

func main() {
	files := []string{"./example.txt", "./input.txt"}
	expected := []int{1588, 2194}

	inputs := make([]string, 0)
	for _, f := range files {
		input, err := file.ReadFile(f)
		if err != nil {
			log.Fatal(err)
			return
		}
		inputs = append(inputs, input)
	}

	for i, input := range inputs {
		fmt.Println(files[i])
		parts := conv.SplitInputByString(input, "\n\n")
		template := parts[0]
		rules := conv.SplitInputByLine(parts[1])

		ans := run(template, rules, 10)
		if ans != uint64(expected[i]) {
			fmt.Printf("Unexpected answer for pt1 '%s'. wanted: %v got: %v ", files[i], expected[i], ans)
			return
		}
		fmt.Println("P1 ==========", ans)
	}

	parts := conv.SplitInputByString(inputs[0], "\n\n")
	template := parts[0]
	rules := conv.SplitInputByLine(parts[1])
	ans := run2(template, rules, 40)
	fmt.Println(ans)

	parts2 := conv.SplitInputByString(inputs[1], "\n\n")
	template2 := parts2[0]
	rules2 := conv.SplitInputByLine(parts2[1])
	ans2 := run2(template2, rules2, 40)
	fmt.Println(ans2)
}

type Pair struct {
	a, b rune
}

func makeRules(inputs []string) map[Pair]rune {
	rules := make(map[Pair]rune)
	for _, input := range inputs {
		parts := strings.SplitN(input, " -> ", 2)
		rules[Pair{rune(parts[0][0]), rune(parts[0][1])}] = rune(parts[1][0])
	}
	return rules
}

func makeInitialMap(template string) map[int]rune {
	initial := make(map[int]rune)
	for i, r := range template {
		initial[i] = r
	}
	return initial
}

func run(template string, rulesInputs []string, steps int) uint64 {
	rules := makeRules(rulesInputs)

	templateMap := makeInitialMap(template)
	nextTemplateMap := make(map[int]rune)
	var product rune
	for j := 0; j < steps; j++ {
		for i := 0; i < len(templateMap)-1; i++ {
			nextTemplateMap[len(nextTemplateMap)] = templateMap[i]
			product = rules[Pair{templateMap[i], templateMap[i+1]}]
			nextTemplateMap[len(nextTemplateMap)] = product
		}
		nextTemplateMap[len(nextTemplateMap)] = templateMap[len(templateMap)-1]

		templateMap = nextTemplateMap
		nextTemplateMap = make(map[int]rune)
	}

	freq := make(map[rune]int)
	for _, v := range templateMap {
		freq[v] += 1
	}

	min := uint64(math.MaxUint64)
	max := uint64(0)
	for _, v := range freq {
		x := uint64(v)
		if x < min {
			min = x
		}
		if x > max {
			max = x
		}
	}

	return max - min
}

func getPairs(template string) map[Pair]int {
	pairs := make(map[Pair]int)
	for i := 0; i < len(template)-1; i++ {
		pairs[Pair{rune(template[i]), rune(template[i+1])}] += 1
	}
	return pairs
}

func makeRules2(inputs []string) map[Pair][]Pair {
	rules := make(map[Pair][]Pair)
	for _, input := range inputs {
		parts := strings.SplitN(input, " -> ", 2)
		e1 := rune(parts[0][0])
		e2 := rune(parts[0][1])
		p := rune(parts[1][0])
		rules[Pair{e1, e2}] = []Pair{{e1, p}, {p, e2}}
	}
	return rules
}

func run2(template string, rulesInputs []string, steps int) uint64 {
	rules := makeRules2(rulesInputs)
	pairs := getPairs(template)

	for i := 0; i < steps; i++ {
		nextPairs := make(map[Pair]int)
		for pair, count := range pairs {
			derivatives := rules[pair]
			for _, derived := range derivatives {
				nextPairs[derived] += count
			}
		}
		pairs = nextPairs
	}

	freq := make(map[rune]int)
	for pair, count := range pairs {
		freq[pair.a] += count
	}
	freq[rune(template[len(template)-1])] += 1

	min := uint64(math.MaxUint64)
	max := uint64(0)
	for _, v := range freq {
		x := uint64(v)
		if x < min {
			min = x
		}
		if x > max {
			max = x
		}
	}

	return max - min
}
