package main

import (
	"advent-of-go/util/file"
	"log"
	"strconv"
	"strings"
)

const exampleFilePath = "./example.txt"
const inputFilePath = "./input.txt"

func main() {
	example, exampleErr := file.ReadFile(exampleFilePath)
	input, inputErr := file.ReadFile(inputFilePath)

	if exampleErr != nil {
		log.Fatal(exampleErr)
		return
	}
	if inputErr != nil {
		log.Fatal(inputErr)
		return
	}

	exampleExpected := uint64(5934)
	exampleAnswer := run(example, 80)
	if exampleAnswer == exampleExpected {
		log.Printf("Example - Part 1: %v", exampleAnswer)
	} else {
		log.Fatalf("Result of part 1 with example input does not match expected:\nexpected: %v got: %v", exampleExpected, exampleAnswer)
	}

	answer1 := run(input, 80)
	log.Printf("Part 1: %v", answer1)

	answer2 := run(input, 256)
	log.Printf("Part 2: %v", answer2)
}

func run(input string, days int) uint64 {
	initialFish := make([]int, 0)
	for _, timer := range strings.Split(input, ",") {
		timerValue, _ := strconv.Atoi(timer)
		initialFish = append(initialFish, timerValue)
	}

	day := make(map[int]int)
	for _, fishTimer := range initialFish {
		day[fishTimer] += 1
	}

	var total uint64 = uint64(len(initialFish))
	var afterDay map[int]int
	for i := 0; i < days; i++ {
		afterDay = make(map[int]int)
		for timer, count := range day {
			if timer == 0 {
				total += uint64(count)
				afterDay[8] = count
				afterDay[6] += count
				continue
			}
			afterDay[timer-1] += count
		}
		day = afterDay
	}

	return total
}
