package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"strconv"
)

const inputFilePath = "./input.txt"

type Comparison int

const (
	Same Comparison = 5
	One  Comparison = 1
	Zero Comparison = 0
)

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
	bits := findMostCommonBitValues(lines)

	num := ""
	for _, bit := range bits {
		if bit == One {
			num += "1"
		} else {
			num += "0"
		}
	}

	gamma, _ := strconv.ParseUint(num, 2, 32)
	epsilon, _ := strconv.ParseUint(invert(num), 2, 32)

	return int(gamma) * int(epsilon), nil
}

func findMostCommonBitValues(lines []string) []Comparison {
	bitLength := len([]rune(lines[0]))
	counts := make([]int, bitLength)

	for _, line := range lines {
		for i, bit := range line {
			if bit == '1' {
				counts[i] += 1
			}
		}
	}

	result := make([]Comparison, bitLength)
	for i, count := range counts {
		uncommon := len(lines) - count
		if count > uncommon {
			result[i] = One
		} else if count == uncommon {
			result[i] = Same
		} else {
			result[i] = Zero
		}
	}

	return result
}

func invert(input string) string {
	inverse := ""
	for _, bit := range input {
		if bit == '1' {
			inverse += "0"
		} else {
			inverse += "1"
		}
	}

	return inverse
}

func Part2(lines []string) (int, error) {
	o2Compare := make(map[int]bool, len(lines))
	co2Compare := make(map[int]bool, len(lines))

	for i := range lines {
		co2Compare[i] = true
		o2Compare[i] = true
	}

	o2stillComparingCount := len(lines)
	for pointer := range lines[0] {
		if o2stillComparingCount == 1 {
			break
		}

		o2LinesToCompare := make([]string, 0, o2stillComparingCount)

		for lineIndex, include := range o2Compare {
			if include {
				o2LinesToCompare = append(o2LinesToCompare, lines[lineIndex])
			}
		}

		bits := findMostCommonBitValues(o2LinesToCompare)

		for i, line := range lines {
			var bit Comparison
			if line[pointer] == '1' {
				bit = One
			} else {
				bit = Zero
			}

			if bits[pointer] == Same {
				if bit == Zero && o2Compare[i] {
					o2Compare[i] = false
					o2stillComparingCount -= 1
				}
				continue
			}

			if o2Compare[i] && bit != bits[pointer] {
				o2Compare[i] = false
				o2stillComparingCount -= 1
			}
		}
	}

	co2stillComparingCount := len(lines)
	for pointer := range lines[0] {
		if co2stillComparingCount == 1 {
			break
		}

		co2LinesToCompare := make([]string, 0, co2stillComparingCount)

		for lineIndex, include := range co2Compare {
			if include {
				co2LinesToCompare = append(co2LinesToCompare, lines[lineIndex])
			}
		}

		bits := findMostCommonBitValues(co2LinesToCompare)

		for i, line := range lines {
			var bit Comparison
			if line[pointer] == '1' {
				bit = One
			} else {
				bit = Zero
			}

			if bits[pointer] == Same {
				if bit == One && co2Compare[i] {
					co2Compare[i] = false
					co2stillComparingCount -= 1
				}
				continue
			}

			if co2Compare[i] && bit == bits[pointer] {
				co2Compare[i] = false
				co2stillComparingCount -= 1
			}
		}
	}

	var o2 string
	for i, value := range o2Compare {
		if value {
			o2 = lines[i]
			break
		}
	}

	var co2 string
	for i, value := range co2Compare {
		if value {
			co2 = lines[i]
			break
		}
	}

	o2Rating, _ := strconv.ParseUint(o2, 2, 32)
	co2Rating, _ := strconv.ParseUint(co2, 2, 32)

	return int(o2Rating) * int(co2Rating), nil
}
