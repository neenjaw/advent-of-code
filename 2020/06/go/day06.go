package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/enum"
	"advent-of-go/util/file"
	"log"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"

func unionMergeGroup(group string) (merged map[rune]int) {
	merged = make(map[rune]int, 0)
	for _, r := range []rune(group) {
		if r < 'a' || r > 'z' {
			continue
		}
		merged[r] = merged[r] + 1
	}
	return
}

func consensusMergeGroup(group string) (merged map[rune]int) {
	merged = make(map[rune]int, 0)
	surveyCount := 1
	for _, r := range []rune(group) {
		if r == '\n' {
			surveyCount += 1
		}
		if r < 'a' || r > 'z' {
			continue
		}
		merged[r] = merged[r] + 1
	}
	for k, v := range merged {
		if v != surveyCount {
			delete(merged, k)
		}
	}
	return
}

func mergeGroups(groups []string, strategy func(string) map[rune]int) (merged []map[rune]int) {
	for _, group := range groups {
		merged = append(merged, strategy(group))
	}
	return
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	groups := conv.SplitInputByString(input, "\n\n")

	unionGroupedSurveys := mergeGroups(groups, unionMergeGroup)
	answer1 := sumKeys(unionGroupedSurveys)
	log.Printf("Part 1: %v", answer1)

	consensusGroupedSurveys := mergeGroups(groups, consensusMergeGroup)
	answer2 := sumKeys(consensusGroupedSurveys)
	log.Printf("Part 2: %v", answer2)
}

func sumKeys(surveyUnion []map[rune]int) int {
	keyCounts := make([]int, 0, len(surveyUnion))
	for _, survey := range surveyUnion {
		keyCounts = append(keyCounts, len(survey))
	}
	return enum.Sum(keyCounts)
}
