package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/enum"
	"advent-of-go/util/file"
	"log"
	"sort"
	"strconv"
)

const inputFilePath = "./input.txt"

func parseLineToSeatNumber(line string) int {
	directives := []rune(line)
	bitstring := []rune{}
	for _, directive := range directives {
		switch directive {
		case 'F':
			bitstring = append(bitstring, '0')
		case 'B':
			bitstring = append(bitstring, '1')
		case 'L':
			bitstring = append(bitstring, '0')
		case 'R':
			bitstring = append(bitstring, '1')
		}
	}
	n, _ := strconv.ParseInt(string(bitstring), 2, 32)
	return int(n)
}

func parseLinesToSeatNumber(lines []string) (n []int) {
	for _, line := range lines {
		n = append(n, parseLineToSeatNumber(line))
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
	seatNumbers := parseLinesToSeatNumber(lines)

	_, answer1 := enum.MaxByIntValue(seatNumbers)
	log.Printf("Part 1: %v", answer1)

	answer2 := findGapInSeatNumbers(seatNumbers)
	log.Printf("Part 2: %v", answer2)
}

func findGapInSeatNumbers(seatNumbers []int) int {
	sort.Ints(seatNumbers)
	for i, seat := range seatNumbers {
		if i == 0 {
			continue
		}

		if seatNumbers[i+1] == seat+2 {
			return seat + 1
		}
	}
	panic("No seat found unexpectedly")
}
