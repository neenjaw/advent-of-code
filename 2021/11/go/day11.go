package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"log"
	"strconv"

	"github.com/fatih/color"
)

const exampleFilePath = "./example.txt"
const inputFilePath = "./input.txt"

func main() {
	// example, exampleErr := file.ReadFile(exampleFilePath)
	// if exampleErr != nil {
	// 	log.Fatal(exampleErr)
	// 	return
	// }

	input, inputErr := file.ReadFile(inputFilePath)
	if inputErr != nil {
		log.Fatal(inputErr)
		return
	}

	// exampleLines := conv.SplitInputByLine(example)
	inputLines := conv.SplitInputByLine(input)

	// example1Expected := 1656
	// example1Answer := run(exampleLines, 100)
	// if example1Answer == example1Expected {
	// 	log.Printf("Example - Part 1: %v", example1Answer)
	// } else {
	// 	log.Fatalf("Result of part 1 with example input does not match expected:\nexpected: %v got: %v", example1Expected, example1Answer)
	// }

	answer1 := run(inputLines, 100000000)
	log.Printf("Part 1: %v", answer1)

	// example2Expected := 288957
	// if example2Answer == example2Expected {
	// 	log.Printf("Example - Part 2: %v", example2Answer)
	// } else {
	// 	log.Fatalf("Result of part 2 with example input does not match expected:\nexpected: %v got: %v", example2Expected, example2Answer)
	// }

	// log.Printf("Part 2: %v", answer2)
}

type C struct {
	y, x int
}

func makeGrid(lines []string) [][]int {
	grid := make([][]int, 0)

	for i, line := range lines {
		grid = append(grid, make([]int, 0))
		for _, o := range line {
			v, _ := strconv.Atoi(string(o))
			grid[i] = append(grid[i], v)
		}
	}

	return grid
}

func validCoord(grid [][]int, c C) bool {
	return c.y >= 0 && c.y < len(grid) && c.x >= 0 && c.x < len(grid[0])
}

func findSurroundingCoords(grid [][]int, c C) []C {
	coords := make([]C, 0)
	rel_coords := []C{{-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}}

	for _, r := range rel_coords {
		abs_coord := C{y: r.y + c.y, x: r.x + c.x}
		if validCoord(grid, abs_coord) {
			coords = append(coords, abs_coord)
		}
	}

	return coords
}

func run(lines []string, steps_to_take int) int {
	grid := makeGrid(lines)
	flashes := 0

	for step := 0; step < steps_to_take; step++ {
		flashed := make(map[C]bool)
		for y, row := range grid {
			for x, _ := range row {
				queue := make([]C, 0)
				queue = append(queue, C{y, x})

				for len(queue) > 0 {
					cell := queue[0]
					queue = queue[1:]

					grid[cell.y][cell.x] += 1

					if grid[cell.y][cell.x] > 9 && !flashed[cell] {
						flashed[cell] = true
						for _, neighbor := range findSurroundingCoords(grid, cell) {
							if _, ok := flashed[neighbor]; !ok {
								queue = append(queue, neighbor)
							}
						}
					}
				}
			}
		}

		for y, row := range grid {
			for x, energy := range row {
				if energy > 9 {
					grid[y][x] = 0
				}
			}
		}

		flashes += len(flashed)

		for _, row := range grid {
			for _, energy := range row {
				if energy == 0 {
					color.Set(color.FgCyan)
					fmt.Print(energy)
					color.Unset()
				} else {
					fmt.Print(energy)
				}
			}
			fmt.Print("\n")
		}
		fmt.Print("\n")
	}

	return flashes
}
