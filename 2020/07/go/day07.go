package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"strconv"
	"strings"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"

type Bag string
type ContentRule map[Bag]int
type Rules map[Bag]ContentRule

const ClauseNeck = " contain "
const NoContent = "no other bags"
const ShinyGoldBag = "shiny gold bags"

func mapReduceBodyToContentRule(body []string) (rule ContentRule) {
	rule = make(ContentRule, 0)
	for _, clause := range body {
		clause = strings.TrimSuffix(clause, "s")
		clause += "s"
		parts := strings.SplitN(clause, " ", 2)
		quantity, _ := strconv.Atoi(parts[0])
		rule[Bag(parts[1])] = quantity
	}
	return
}

func parseRule(line string) (Bag, ContentRule) {
	parts := strings.SplitN(line, ClauseNeck, 2)
	head, body := parts[0], strings.Split(strings.TrimSuffix(parts[1], "."), ", ")

	if body[0] == NoContent {
		return Bag(head), make(ContentRule, 0)
	}

	return Bag(head), mapReduceBodyToContentRule(body)
}

func parseRules(lines []string) (rules Rules) {
	rules = make(map[Bag]ContentRule, 0)

	for _, line := range lines {
		bag, contents := parseRule(line)
		rules[bag] = contents
	}

	return
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)
	rules := parseRules(lines)

	answer1 := countPathsToGoldBag(rules)
	log.Printf("Part 1: %v", answer1)

	answer2 := traverseBagSum(ShinyGoldBag, rules)
	log.Printf("Part 2: %v", answer2)
}

func countPathsToGoldBag(rules Rules) (count int) {
	for bag := range rules {
		if bag == ShinyGoldBag {
			continue
		}

		if search(bag, rules) {
			count += 1
		}
	}

	return
}

func search(start_bag Bag, rules Rules) bool {
	visited := make(map[Bag]bool, 0)
	queue := []Bag{start_bag}
	for {
		currentBag := queue[0]
		if currentBag == ShinyGoldBag {
			return true
		}

		visited[currentBag] = true
		queue = queue[1:]
		content := rules[currentBag]

		for childBag := range content {
			if _, visited := visited[childBag]; !visited {
				queue = append(queue, childBag)
			}
		}

		if len(queue) == 0 {
			return false
		}
	}
}

func traverseBagSum(bag Bag, rules Rules) (count int) {
	for childBag, quantity := range rules[bag] {
		count += quantity + quantity*traverseBagSum(childBag, rules)
	}
	return
}
