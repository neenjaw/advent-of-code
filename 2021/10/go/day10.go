package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"errors"
	"log"
	"sort"
)

const exampleFilePath = "./example.txt"
const inputFilePath = "./input.txt"

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

	exampleLines := conv.SplitInputByLine(example)
	inputLines := conv.SplitInputByLine(input)

	example1Expected := 26397
	example1Answer, example2Answer := run(exampleLines)
	if example1Answer == example1Expected {
		log.Printf("Example - Part 1: %v", example1Answer)
	} else {
		log.Fatalf("Result of part 1 with example input does not match expected:\nexpected: %v got: %v", example1Expected, example1Answer)
	}

	answer1, answer2 := run(inputLines)
	log.Printf("Part 1: %v", answer1)

	example2Expected := 288957
	if example2Answer == example2Expected {
		log.Printf("Example - Part 2: %v", example2Answer)
	} else {
		log.Fatalf("Result of part 2 with example input does not match expected:\nexpected: %v got: %v", example2Expected, example2Answer)
	}

	log.Printf("Part 2: %v", answer2)
}

type BracketType int

var errorPointIndex map[BracketType]int
var incompletePointIndex map[BracketType]int

func init() {
	errorPointIndex = make(map[BracketType]int)
	errorPointIndex[ParenClose] = 3
	errorPointIndex[SquareClose] = 57
	errorPointIndex[CurlyClose] = 1197
	errorPointIndex[AngleClose] = 25137

	incompletePointIndex = make(map[BracketType]int)
	incompletePointIndex[ParenClose] = 1
	incompletePointIndex[SquareClose] = 2
	incompletePointIndex[CurlyClose] = 3
	incompletePointIndex[AngleClose] = 4
	incompletePointIndex[ParenOpen] = 1
	incompletePointIndex[SquareOpen] = 2
	incompletePointIndex[CurlyOpen] = 3
	incompletePointIndex[AngleOpen] = 4
}

const (
	ParenOpen   BracketType = '('
	ParenClose  BracketType = ')'
	SquareOpen  BracketType = '['
	SquareClose BracketType = ']'
	CurlyOpen   BracketType = '{'
	CurlyClose  BracketType = '}'
	AngleOpen   BracketType = '<'
	AngleClose  BracketType = '>'
)

func isMatchingPair(a, b BracketType) bool {
	return (a == ParenOpen && b == ParenClose) ||
		(a == SquareOpen && b == SquareClose) ||
		(a == CurlyOpen && b == CurlyClose) ||
		(a == AngleOpen && b == AngleClose)
}

func isOpeningBracket(a BracketType) bool {
	return a == ParenOpen || a == SquareOpen || a == CurlyOpen || a == AngleOpen
}

func isClosingBracket(a BracketType) bool {
	return a == ParenClose || a == SquareClose || a == CurlyClose || a == AngleClose
}

type RuneStack []BracketType

func (s *RuneStack) peek() (BracketType, error) {
	if len(*s) == 0 {
		return 0, errors.New("nothing to pop")
	}

	return (*s)[len(*s)-1], nil
}

func (s *RuneStack) push(r BracketType) {
	*s = append(*s, r)
}

func (s *RuneStack) pop() (BracketType, error) {
	if len(*s) == 0 {
		return 0, errors.New("nothing to pop")
	}

	top := (*s)[len(*s)-1]
	*s = (*s)[0 : len(*s)-1]
	return top, nil
}

func processLine(line string) (int, int) {
	stack := make(RuneStack, 0)
	for _, r := range line {
		b := BracketType(r)
		if isOpeningBracket(b) {
			stack.push(b)
			continue
		}

		if isClosingBracket(b) {
			top, err := stack.peek()
			if err != nil || !isMatchingPair(top, b) {
				return errorPointIndex[b], 0
			}
			stack.pop()
		}
	}

	points := 0
	for i := len(stack) - 1; i >= 0; i-- {
		points *= 5
		points += incompletePointIndex[stack[i]]
	}

	return 0, points
}

func run(lines []string) (totalErrorPoints int, medianIncompletePoints int) {
	points := make([]int, 0)
	for _, line := range lines {
		errorPoints, incompletePoints := processLine(line)
		totalErrorPoints += errorPoints
		if incompletePoints != 0 {
			points = append(points, incompletePoints)
		}
	}

	sort.Ints(points)
	i := len(points) / 2

	medianIncompletePoints = points[i]
	return
}
