package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"log"
	"strconv"
	"strings"
)

const inputFilePath = "./input.txt"

type PasswordPolicy struct {
	a        int
	b        int
	letter   rune
	password string
}

func parseLineToPasswordPolicy(line string) (PasswordPolicy, error) {
	parts := strings.Split(line, ": ")
	password := parts[1]
	policy_parts := strings.Split(parts[0], " ")
	letter := conv.FirstRune(policy_parts[1])
	positions := strings.Split(policy_parts[0], "-")
	a, _ := strconv.Atoi(positions[0])
	b, _ := strconv.Atoi(positions[1])

	return PasswordPolicy{a, b, letter, password}, nil
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)
	policies := make([]PasswordPolicy, 0, len(lines))
	for _, line := range lines {
		policy, err := parseLineToPasswordPolicy(line)

		if err != nil {
			panic(fmt.Sprintf("'%v' does not create a valid policy", line))
		}
		policies = append(policies, policy)
	}

	answer1 := Part1(policies)
	log.Printf("Part 1: %v", answer1)

	answer2 := Part2(policies)
	log.Printf("Part 2: %v", answer2)
}

func Part1(policies []PasswordPolicy) int {
	count := 0

	for _, policy := range policies {
		runeCount := 0
		for _, rune := range policy.password {
			if rune == policy.letter {
				runeCount += 1
			}
		}
		if runeCount >= policy.a && runeCount <= policy.b {
			count += 1
		}
	}
	return count
}

func Part2(policies []PasswordPolicy) int {
	count := 0

	for _, policy := range policies {
		passwordRunes := []rune(policy.password)
		aIsLetter := passwordRunes[policy.a-1] == policy.letter
		bIsLetter := passwordRunes[policy.b-1] == policy.letter

		if (aIsLetter || bIsLetter) && !(aIsLetter && bIsLetter) {
			count += 1
		}
	}
	return count
}
