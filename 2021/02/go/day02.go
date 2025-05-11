package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"strconv"
	"strings"
)

const inputFilePath = "./input.txt"

const forward = "forward"
const down = "down"
const up = "up"

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)

	if err != nil {
		log.Fatal(err)
		return
	}

	answer1, e := Part1(lines)
	log.Printf("Part 1: %v, err: %v", answer1, e)

	answer2, e := Part2(lines)
	log.Printf("Part 2: %v, err: %v", answer2, e)
}

func Part1(lines []string) (int, error) {
	x, y := 0, 0

	for _, line := range lines {
		parts := strings.Split(strings.TrimSpace(line), " ")
		direction := parts[0]
		value, _ := strconv.Atoi(parts[1])

		if direction == forward {
			x += value
		} else if direction == up {
			y -= value
		} else if direction == down {
			y += value
		}
	}

	return x * y, nil
}

func Part2(lines []string) (int, error) {
	x, y, aim := 0, 0, 0

	for _, line := range lines {
		parts := strings.Split(strings.TrimSpace(line), " ")
		direction := parts[0]
		value, _ := strconv.Atoi(parts[1])

		if direction == forward {
			x += value
			y += value * aim
		} else if direction == up {
			aim -= value
		} else if direction == down {
			aim += value
		}
	}

	return x * y, nil
}
