package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/enum"
	"advent-of-go/util/file"
	"advent-of-go/util/strhelper"
	"fmt"
	"log"
	"strings"
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

func run(inputs []string) (count int) {
	for _, input := range inputs {
		digits := strings.Fields((strings.SplitN(input, " | ", 2))[1])
		for _, digit := range digits {
			lengths := []int{2, 3, 4, 7}
			if enum.ContainsInt(lengths, len(digit)) {
				count += 1
			}
		}
	}
	return
}

type Bits uint8

const (
	A Bits = 1 << iota
	B
	C
	D
	E
	F
	G
)

var DIGITS map[Bits]int

func init() {
	DIGITS = make(map[Bits]int)
	DIGITS[0x7f & ^D] = 0
	DIGITS[C|F] = 1
	DIGITS[0x7f & ^(B|F)] = 2
	DIGITS[0x7f & ^(B|E)] = 3
	DIGITS[B|C|D|F] = 4
	DIGITS[0x7f & ^(C|E)] = 5
	DIGITS[0x7f & ^C] = 6
	DIGITS[A|C|F] = 7
	DIGITS[0x7f] = 8
	DIGITS[0x7f & ^E] = 9
}

func selectBySize(x []string, size int) string {
	needle, err := enum.Find(x, func(s string) bool { return len(s) == size })
	if err != nil {
		panic(err)
	}
	return needle
}

func breaker(samples []string, digits []string) int {
	code1 := selectBySize(samples, 2)
	code7 := selectBySize(samples, 3)
	code4 := selectBySize(samples, 4)

	a := strhelper.StringDiff(code7, code1)
	frequencies := strhelper.RuneFrequency(strings.Join(samples, ""))
	mapping := make(map[rune]Bits)
	mapper := func(r rune, frequency int) Bits {
		switch frequency {
		case 4:
			return E
		case 6:
			return B
		case 7:
			if strings.ContainsRune(code4, r) {
				return D
			}
			return G
		case 8:
			if r == []rune(a)[0] {
				return A
			}
			return C
		case 9:
			return F
		default:
			panic(fmt.Sprintf("bad freq %v %v %v", mapping, r, frequency))
		}
	}

	for r, frequency := range frequencies {
		mapping[r] = mapper(r, frequency)
	}
	if len(mapping) != 7 {
		panic(fmt.Sprintf("bad mapping %v", mapping))
	}

	acc := 0
	for _, digit := range digits {
		value := Bits(0)
		for _, r := range digit {
			value += mapping[r]
		}

		acc *= 10
		acc += DIGITS[value]
	}

	return acc
}

func runBreaker(inputs []string) (sum int) {
	for _, input := range inputs {
		parts := strings.SplitN(input, " | ", 2)
		samples := strings.Fields(parts[0])
		digits := strings.Fields(parts[1])
		sum += breaker(samples, digits)
	}

	return
}
