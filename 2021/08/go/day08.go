package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"sort"
	"strconv"
	"strings"
)

const exampleFilePath = "./example.txt"
const inputFilePath = "./input.txt"

type sortRunes []rune

func (s sortRunes) Less(i, j int) bool {
	return s[i] < s[j]
}

func (s sortRunes) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s sortRunes) Len() int {
	return len(s)
}

func SortString(s string) string {
	r := []rune(s)
	sort.Sort(sortRunes(r))
	return string(r)
}

type CodeBlock struct {
	digits  []string
	encoded []string
}

func processLine(codeInput string) CodeBlock {
	sides := strings.SplitN(codeInput, " | ", 2)

	left_side := strings.Fields(sides[0])
	sort.Slice(left_side, func(i, j int) bool {
		return len(left_side[i]) < len(left_side[j])
	})
	for i := 0; i < len(left_side); i++ {
		left_side[i] = SortString(left_side[i])
	}

	right_side := strings.Fields(sides[1])
	for i := 0; i < len(right_side); i++ {
		right_side[i] = SortString(right_side[i])
	}

	return CodeBlock{left_side, right_side}
}

func processLines(inputs []string) []CodeBlock {
	blocks := make([]CodeBlock, 0)
	for _, input := range inputs {
		blocks = append(blocks, processLine(input))
	}
	return blocks
}

func main() {
	example, exampleErr := file.ReadFile(exampleFilePath)
	if exampleErr != nil {
		log.Fatal(exampleErr)
		return
	}

	input, inputErr := file.ReadFile(inputFilePath)
	if inputErr != nil {
		log.Fatal(inputErr)
		return
	}

	exampleCodes := conv.SplitInputByLine(example)
	inputCodes := conv.SplitInputByLine(input)

	example1Expected := 26
	example1Answer := run(exampleCodes)
	if example1Answer == example1Expected {
		log.Printf("Example - Part 1: %v", example1Answer)
	} else {
		log.Fatalf("Result of part 1 with example input does not match expected:\nexpected: %v got: %v", example1Expected, example1Answer)
	}

	answer1 := run(inputCodes)
	log.Printf("Part 1: %v", answer1)

	example2Expected := 61229
	example2Answer := runBreaker(exampleCodes)
	if example2Answer == example2Expected {
		log.Printf("Example - Part 2: %v", example2Answer)
	} else {
		log.Fatalf("Result of part 2 with example input does not match expected:\nexpected: %v got: %v", example2Expected, example2Answer)
	}

	answer2 := runBreaker(inputCodes)
	log.Printf("Part 2: %v", answer2)
}

func run(inputs []string) int {
	count := 0
	for _, input := range inputs {
		digits := strings.Fields((strings.Split(input, " | "))[1])
		for _, digit := range digits {
			if len(digit) == 2 || len(digit) == 3 || len(digit) == 4 || len(digit) == 7 {
				count += 1
			}
		}
	}
	return count
}

func runBreaker(inputs []string) int {
	codes := processLines(inputs)

	sum := 0
	for _, code := range codes {
		lookup := make(map[int]string, 0)

		for _, digit := range code.digits {
			switch len(digit) {
			case 2:
				lookup[1] = digit
			case 3:
				lookup[7] = digit
			case 4:
				lookup[4] = digit
			case 7:
				lookup[8] = digit
			}
		}

		encodedNumber := ""
		for _, encodedDigit := range code.encoded {
			switch {
			case encodedDigit == lookup[8]:
				encodedNumber += "8"
			case encodedDigit == lookup[7]:
				encodedNumber += "7"
			case encodedDigit == lookup[4]:
				encodedNumber += "4"
			case encodedDigit == lookup[1]:
				encodedNumber += "1"
			case chain_diff(lookup[8], []string{encodedDigit, lookup[1], lookup[4]}, []int{1, 1, 1}):
				encodedNumber += "9"
			case chain_diff(lookup[8], []string{encodedDigit, lookup[1]}, []int{1, 0}):
				encodedNumber += "6"
			case chain_diff(lookup[8], []string{encodedDigit, lookup[4]}, []int{2, 0}):
				encodedNumber += "2"
			case chain_diff(lookup[8], []string{encodedDigit, lookup[1]}, []int{2, 2}):
				encodedNumber += "3"
			case chain_diff(lookup[8], []string{encodedDigit, lookup[4]}, []int{2, 1}):
				encodedNumber += "5"
			case chain_diff(lookup[8], []string{encodedDigit}, []int{1}):
				encodedNumber += "0"
			default:
				panic("unknown digit")
			}
		}
		value, _ := strconv.Atoi(encodedNumber)
		sum += value
	}

	return sum
}

func diff(a, b string) string {
	mb := make(map[rune]bool, len(b))
	for _, x := range b {
		mb[x] = true
	}
	var diff string
	for _, x := range a {
		if _, found := mb[x]; !found {
			diff = diff + string(x)
		}
	}
	return diff
}

func chain_diff(enc string, steps []string, check []int) bool {
	d := enc
	for i, step := range steps {
		d1 := diff(d, step)
		if len(d1) != check[i] {
			return false
		}
		d = d1
	}

	return true
}
