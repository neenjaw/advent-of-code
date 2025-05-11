package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"sort"
	"strconv"
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

	example1Expected := 15
	example1Answer := run(exampleCodes)
	if example1Answer == example1Expected {
		log.Printf("Example - Part 1: %v", example1Answer)
	} else {
		log.Fatalf("Result of part 1 with example input does not match expected:\nexpected: %v got: %v", example1Expected, example1Answer)
	}

	answer1 := run(inputCodes)
	log.Printf("Part 1: %v", answer1)

	example2Expected := 1134
	example2Answer := run2(exampleCodes)
	if example2Answer == example2Expected {
		log.Printf("Example - Part 2: %v", example2Answer)
	} else {
		log.Fatalf("Result of part 2 with example input does not match expected:\nexpected: %v got: %v", example2Expected, example2Answer)
	}

	answer2 := run2(inputCodes)
	log.Printf("Part 2: %v", answer2)
}

type Coord struct {
	y, x int
}

func run(inputs []string) (threat_sum int) {
	grid := make([][]int, len(inputs))
	for i, input := range inputs {
		grid[i] = make([]int, 0, len(input))
		for _, r := range input {
			v, _ := strconv.Atoi(string(r))
			grid[i] = append(grid[i], v)
		}
	}

	rel_coords := []Coord{{-1, 0}, {1, 0}, {0, 1}, {0, -1}}

	for y, row := range grid {
	col_loop:
		for x, cell_value := range row {
			for _, rel_coord := range rel_coords {
				abs_coord := Coord{y: rel_coord.y + y, x: rel_coord.x + x}
				if validCoord(grid, abs_coord) && grid[abs_coord.y][abs_coord.x] <= cell_value {
					continue col_loop
				}
			}
			threat_sum += cell_value + 1
		}
	}
	return
}

func validCoord(grid [][]int, c Coord) bool {
	return c.y >= 0 && c.y < len(grid) && c.x >= 0 && c.x < len(grid[0])
}

func run2(inputs []string) (threat_product int) {
	grid := make([][]int, len(inputs))
	for i, input := range inputs {
		grid[i] = make([]int, 0, len(input))
		for _, r := range input {
			v, _ := strconv.Atoi(string(r))
			grid[i] = append(grid[i], v)
		}
	}

	basin_sizes := make([]int, 0)
	visited := make(map[Coord]bool)
	for y, row := range grid {
		for x, col := range row {
			if (visited[Coord{y: y, x: x}]) {
				continue
			}

			if col == 9 {
				visited[Coord{y: y, x: x}] = true
				continue
			}

			area := expandArea(grid, &visited, Coord{y: y, x: x})
			if area > 0 {
				basin_sizes = append(basin_sizes, area)
			}
		}
	}

	sort.Slice(basin_sizes, func(i, j int) bool {
		return basin_sizes[i] > basin_sizes[j]
	})

	threat_product = 1
	for i := 0; i < 3; i++ {
		threat_product *= basin_sizes[i]
	}
	return
}

func expandArea(grid [][]int, visited *map[Coord]bool, start Coord) (area int) {
	queue := []Coord{start}
	rel_coords := []Coord{{-1, 0}, {1, 0}, {0, 1}, {0, -1}}

	for len(queue) > 0 {
		locus := queue[0]
		queue = queue[1:]

		if !validCoord(grid, locus) || (*visited)[locus] {
			continue
		}

		(*visited)[locus] = true

		if grid[locus.y][locus.x] == 9 {
			continue
		}

		for _, rel_coord := range rel_coords {
			abs_coord := Coord{y: rel_coord.y + locus.y, x: rel_coord.x + locus.x}
			queue = append(queue, abs_coord)
		}
		area += 1
	}
	return
}
