package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"log"
)

const inputFilePath = "./input.txt"

type LineKey struct {
	x int
	y int
}

type Line struct {
	x1 int
	y1 int
	x2 int
	y2 int
}

func parseLineInputIntoLine(lineInput string) Line {
	var x1, y1, x2, y2 int
	fmt.Sscanf(lineInput, "%d,%d -> %d,%d", &x1, &y1, &x2, &y2)

	return Line{x1, y1, x2, y2}
}

func parseLineInputsIntoLine(lineInputs []string) []Line {
	lines := make([]Line, 0)
	for _, input := range lineInputs {
		lines = append(lines, parseLineInputIntoLine(input))
	}
	return lines
}

func filterHVLines(lines []Line) []Line {
	filtered := make([]Line, 0)
	for _, line := range lines {
		if line.x1 == line.x2 || line.y1 == line.y2 {
			filtered = append(filtered, line)
		}
	}

	return filtered
}

func buildGrid(lines []Line) *map[LineKey]int {
	grid := make(map[LineKey]int)
	for _, line := range lines {
		drawLine(&grid, line)
	}
	return &grid
}

func drawLine(grid *map[LineKey]int, line Line) {
	var dx, dy int

	switch {
	case line.x1 < line.x2:
		dx = 1
	case line.x1 > line.x2:
		dx = -1
	default:
		dx = 0
	}
	switch {
	case line.y1 < line.y2:
		dy = 1
	case line.y1 > line.y2:
		dy = -1
	default:
		dy = 0
	}

	for done, x, y := false, line.x1, line.y1; !done; x, y = x+dx, y+dy {
		(*grid)[LineKey{x, y}] += 1

		if x == line.x2 && y == line.y2 {
			done = true
		}
	}
}

func countPeaks(grid *map[LineKey]int) int {
	count := 0
	for _, v := range *grid {
		if v >= 2 {
			count += 1
		}
	}
	return count
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lineInputs := conv.SplitInputByLine(input)
	lines := parseLineInputsIntoLine(lineInputs)

	hvLines := filterHVLines(lines)
	grid := buildGrid(hvLines)
	answer1 := countPeaks(grid)
	log.Printf("Part 1: %v", answer1)

	grid2 := buildGrid(lines)
	answer2 := countPeaks(grid2)
	log.Printf("Part 2: %v", answer2)
}
