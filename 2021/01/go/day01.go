package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
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

	answer1, e := Part1(numbers)
	log.Printf("Part 1: %v, err: %v", answer1, e)

	answer2, e := Part2(numbers)
	log.Printf("Part 2: %v, err: %v", answer2, e)
}

func Part1(numbers []int) (int, error) {
	count := 0

	for i, depth := range numbers {
		if i == 0 {
			continue
		}

		if depth > numbers[i-1] {
			count += 1
		}
	}

	return count, nil
}

func Part2(numbers []int) (int, error) {
	count := 0
	for i := 0; i < len(numbers)-3; i++ {
		a := numbers[i] + numbers[i+1] + numbers[i+2]
		b := numbers[i+1] + numbers[i+2] + numbers[i+3]
		if b > a {
			count += 1
		}
	}
	return count, nil
}
