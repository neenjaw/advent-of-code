package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"sort"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"
const smallExampleFilePath = "./small_example.txt"

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	adapters, _ := conv.ConvInputToIntegers(input)
	sort.Ints(adapters)
	deviceRating := adapters[len(adapters)-1] + 3
	diff1Count, diff3Count := countJoltDifferences(adapters, deviceRating)
	answer1 := diff1Count * diff3Count
	log.Printf("Part 1: %v", answer1)

	answer2 := part2(adapters, deviceRating)
	log.Printf("Part 2: %v", answer2)
}

func countJoltDifferences(adapters []int, deviceRating int) (diff1Count, diff3Count int) {
	adapters = append(adapters, deviceRating)
	for i, adapter := range adapters {
		var prevAdapter int
		if i != 0 {
			prevAdapter = adapters[i-1]
		}
		diff := adapter - prevAdapter

		if diff == 1 {
			diff1Count += 1
		}
		if diff == 3 {
			diff3Count += 1
		}
		// fmt.Println(i, prevAdapter, adapter, diff, diff1Count, diff3Count)
	}
	return
}

func part2(adapters []int, deviceRating int) int {
	adapters = append([]int{0}, adapters...)
	adapters = append(adapters, deviceRating)
	history := make(map[int]int)

	traverse(adapters, &history)

	return history[0]
}

func traverse(adapters []int, history *map[int]int) {
	current_adapter := adapters[0]

	if len(adapters) == 1 {
		(*history)[current_adapter] = 1
		return
	}

	remainingAdapters := adapters[1:]
	possibleNextAdapters := [][]int{}
	for i, adapter := range remainingAdapters {
		if adapter-3 > current_adapter {
			break
		}
		possibleNextAdapters = append(possibleNextAdapters, remainingAdapters[i:])
	}

	pathsFromCurrent := 0
	for _, nextAdapters := range possibleNextAdapters {
		if _, ok := (*history)[nextAdapters[0]]; !ok {
			traverse(nextAdapters, history)
		}
		pathsFromCurrent += (*history)[nextAdapters[0]]
	}
	(*history)[current_adapter] = pathsFromCurrent
}
