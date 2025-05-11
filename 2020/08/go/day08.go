package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
)

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)
	code := parseInstructions(lines)

	answer1 := runUntilLoop(code)
	log.Printf("Part 1: %v", answer1)

	answer2 := runWithNaiveSingleChange(code)
	log.Printf("Part 2: %v", answer2)
}

func runUntilLoop(code []Instruction) int {
	visitedInstructions := make(map[int]bool, 0)
	p := 0
	acc := 0
	for {
		if _, visited := visitedInstructions[p]; visited {
			break
		}
		visitedInstructions[p] = true
		p, acc = code[p].Evaluate(p, acc)
	}
	return acc
}

func runWithNaiveSingleChange(code []Instruction) int {
	decisionPoints := findDecisionPoints(code)
	decisions := mapDecisionPointsToDecisions(decisionPoints)

	for _, decision := range decisions {
		p, acc, visitedCode := 0, 0, map[int]bool{}

		for {
			if p == len(code) {
				return acc
			}
			_, hasVisited := visitedCode[p]
			if p < 0 || p > len(code) || hasVisited {
				break
			}
			instruction := code[p]
			if decision.p == p && decision.invert {
				instruction = Invert(instruction)
			}
			visitedCode[p] = true
			p, acc = instruction.Evaluate(p, acc)
		}
	}
	panic("something shoulda worked")
}

func findDecisionPoints(code []Instruction) []int {
	decisionPoints := []int{}
	for i, instruction := range code {
		if instruction.Type() != Acc {
			decisionPoints = append(decisionPoints, i)
		}
	}
	return decisionPoints
}

type Decision struct {
	p      int
	invert bool
}

func mapDecisionPointsToDecisions(points []int) []Decision {
	decisions := make([]Decision, 0, len(points))
	for _, point := range points {
		decisions = append(decisions, Decision{point, true}, Decision{point, false})
	}
	return decisions
}

// type History struct {
// 	visited map[int]bool
// 	p       int
// 	acc     int
// }

// Tried to make a better incremental runner,
// but something strange going on.

// func runWithSingleChange(code []Instruction) int {
// 	history := History{
// 		visited: make(map[int]bool, 0),
// 		p:       0,
// 		acc:     0,
// 	}
// 	histories := []History{history}
// 	inverted := false
// 	invertPointer := -1
// 	terminalP := len(code)

// 	for {
// 		instruction := code[history.p]
// 		history.visited[history.p] = true

// 		if history.p == terminalP {
// 			break
// 		}

// 		if _, visited := history.visited[history.p]; visited || history.p < 0 {
// 			histories = histories[0 : len(histories)-1]
// 			history = histories[len(histories)-1]
// 			inverted = false
// 			log.Printf("backtrack: %#v", history)
// 		}

// 		if !inverted && invertPointer < history.p && CanInvert(instruction) {
// 			invertPointer = history.p
// 			log.Println(invertPointer)
// 			inverted = true
// 			instruction = Invert(instruction)
// 			log.Printf("diverge: %#v, ", instruction)
// 			histories = append(histories, copyHistory(history))
// 			history = histories[len(histories)-1]
// 		}
// 		log.Printf("before:\n\t%#v\n", history)
// 		history.p, history.acc = instruction.Evaluate(history.p, history.acc)

// 		log.Printf("after:\n\t%#v\n", history)

// 		log.Printf("%v %v", history.p, history.acc)
// 	}

// 	return history.acc
// }

// func copyHistory(history History) (h History) {
// 	h = History{
// 		p:       history.p,
// 		acc:     history.acc,
// 		visited: make(map[int]bool),
// 	}

// 	for k, v := range history.visited {
// 		h.visited[k] = v
// 	}
// 	return
// }
