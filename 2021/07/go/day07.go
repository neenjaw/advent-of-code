package main

import (
	"advent-of-go/util/enum"
	"advent-of-go/util/file"
	"log"
	"strconv"
	"strings"
)

const exampleFilePath = "./example.txt"
const inputFilePath = "./input.txt"

func main() {
	example, exampleErr := file.ReadFile(exampleFilePath)
	input, inputErr := file.ReadFile(inputFilePath)

	if exampleErr != nil {
		log.Fatal(exampleErr)
		return
	}
	if inputErr != nil {
		log.Fatal(inputErr)
		return
	}

	example1Expected := 37
	example1Answer, example1Position := run(example, totalSum)
	if example1Answer == example1Expected {
		log.Printf("Example - Part 1: %v", example1Answer)
	} else {
		log.Fatalf("Result of part 1 with example input does not match expected:\nexpected: %v got: %v position: %v", example1Expected, example1Answer, example1Position)
	}

	answer1, _ := run(input, totalSum)
	log.Printf("Part 1: %v", answer1)

	example2Expected := 168
	example2Answer, example2Position := run(example, totalGeoSum)
	if example2Answer == example2Expected {
		log.Printf("Example - Part 2: %v", example2Answer)
	} else {
		log.Fatalf("Result of part 2 with example input does not match expected:\nexpected: %v got: %v position: %v", example2Expected, example2Answer, example2Position)
	}

	answer2, _ := run(input, totalGeoSum)
	log.Printf("Part 2: %v", answer2)
}

func run(input string, sum func([]int, int) int) (int, int) {
	positions := make([]int, 0)
	for _, position_input := range strings.Split(input, ",") {
		position, _ := strconv.Atoi(position_input)
		positions = append(positions, position)
	}

	_, max := enum.MaxByIntValue(positions)

	var min int
	var position int = 0
	for i := 0; i <= max; i++ {
		total := sum(positions, i)
		if i == 0 {
			min = total
			continue
		}
		if total < min {
			position = i
			min = total
		}
	}

	return min, position
}

func totalSum(positions []int, target int) int {
	total := 0
	for _, position := range positions {
		total += abs(position - target)
	}
	return total
}

func totalGeoSum(positions []int, target int) int {
	total := 0
	for _, position := range positions {
		n := abs(position - target)
		total += n * (n + 1) / 2
	}
	return total
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}
