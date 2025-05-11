package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"errors"
	"log"
)

const inputFilePath = "./input.txt"

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	numbers, err := conv.ConvInputToIntegers(input)

	if err != nil {
		log.Fatal(err)
		return
	}

	answer1, e := Part1(numbers, 2020)
	log.Printf("Part 1: %v, err: %v", answer1, e)

	answer2, e := Part2(numbers, 2020)
	log.Printf("Part 2: %v, err: %v", answer2, e)
}

func Part1(numbers []int, goal int) (int, error) {
	for i, a := range numbers {
		for j, b := range numbers {
			if i == j {
				continue
			}

			if a+b == goal {
				return a * b, nil
			}
		}
	}

	return 0, errors.New("No solution")
}

func Part2(numbers []int, goal int) (int, error) {
	for i, a := range numbers {
		ans, err := Part1(numbers[i+1:], goal-a)
		if err != nil {
			continue
		}
		return a * ans, nil
	}

	return 0, errors.New("No solution")
}
