package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"errors"
	"log"

	"github.com/adam-lavrik/go-imath/ix"
	"gonum.org/v1/gonum/stat/combin"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	numbers, _ := conv.ConvInputToIntegers(input)

	answer1, _ := findNumber(numbers, 25)
	log.Printf("Part 1: %v", answer1)

	set, _ := findSumSet(numbers, answer1)
	min, max := ix.MinMaxSlice(set)
	answer2 := min + max
	log.Printf("Part 2: %v", answer2)
}

func findNumber(numbers []int, preamble int) (int, error) {
OUTER:
	for i := preamble; i < len(numbers); i++ {
		value := numbers[i]
		window := numbers[i-preamble : i]
		combinations := combin.Combinations(preamble, 2)

		for _, combination := range combinations {
			p1, p2 := combination[0], combination[1]
			n1, n2 := window[p1], window[p2]

			if n1+n2 == value {
				continue OUTER
			}
		}
		return value, nil
	}

	return 0, errors.New("no value found")
}

func findSumSet(numbers []int, target int) ([]int, error) {
	start, end := 0, 0
	sum := numbers[0]

	for {
		if sum == target {
			return numbers[start : end+1], nil
		}

		if sum < target {
			end += 1
			sum += numbers[end]
		} else if sum > target {
			sum -= numbers[start]
			start += 1
		}

		if start > end || end == len(numbers) {
			return nil, errors.New("cannot create sum set from supplied numbers")
		}
	}
}
