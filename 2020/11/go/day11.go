package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)
	startingArrangement := ConvInputToSeatingArrangement(lines)

	answer1 := part1(startingArrangement)
	log.Printf("Part 1: %v", answer1)

	answer2 := part2(startingArrangement)
	log.Printf("Part 2: %v", answer2)
}

func part1(arr Arrangement) int {
	solution := stepUntilStable(arr, StepConfig{fillThreshold: 0, emptyThreshold: 4, limit: true})

	return CountOccupied(solution)
}

func part2(arr Arrangement) int {
	solution := stepUntilStable(arr, StepConfig{fillThreshold: 0, emptyThreshold: 5, limit: false})

	return CountOccupied(solution)
}

func stepUntilStable(arr Arrangement, config StepConfig) (stable Arrangement) {
	for {
		next, changed := Step(arr, config)

		if !changed {
			stable = next
			break
		}

		arr = next
	}
	return
}
