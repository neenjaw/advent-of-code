package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
)

type Limit struct {
	min, max int
}

type Run struct {
	file     string
	expected int64
}

func main() {
	runs := []Run{
		{"example.txt", 58},
		{"input.txt", -1},
	}

	runs2 := []Run{
		// {"example.txt", 39, false, Limit{}},
		// {"example2.txt", 590784, false, Limit{}},
		// {"input.txt", -1, false, Limit{}},
	}

	for i, run := range runs {
		do_main(i, run)
	}

	for i, run := range runs2 {
		do_main(i, run)
	}
}

type Spot int

const (
	Empty Spot = iota
	East
	South
)

func parseGrid(input string) [][]Spot {
	grid := [][]Spot{}
	for y, line := range conv.SplitInputByLine(input) {
		grid = append(grid, []Spot{})
		for _, c := range line {
			switch c {
			case '.':
				grid[y] = append(grid[y], Empty)
			case '>':
				grid[y] = append(grid[y], East)
			case 'v':
				grid[y] = append(grid[y], South)
			}
		}
	}
	return grid
}

func do_main(i int, run Run) {
	fileContent, _ := file.ReadFile(run.file)
	grid := parseGrid(fileContent)

	fmt.Println("test")
	for _, row := range grid {
		fmt.Println(row)
	}
	ans := simulate(grid)
	if int64(ans) != run.expected {
		fmt.Printf("[FAIL] %d: expected: %v go: %v\n", i, run.expected, ans)
		return
	} else {
		fmt.Printf("[PASS] %d: expected: %v got: %v\n", i, run.expected, ans)
	}
}

type Position struct {
	z, y, x int
}

func simulate(grid [][]Spot) (step int) {
	for {
		change := false
		step += 1
		nextGrid := [][]Spot{}
		for y, row := range grid {
			nextGrid = append(nextGrid, make([]Spot, len(row)))

			for x, c := range row {
				if c != East {
					continue
				}

				nextX := (x + 1) % len(row)
				if grid[y][nextX] == Empty {
					nextGrid[y][nextX] = East
					change = true
				} else {
					nextGrid[y][x] = East
				}
			}
		}

		for y, row := range grid {
			for x, c := range row {
				if c != South {
					continue
				}

				nextY := (y + 1) % len(grid)
				if nextGrid[nextY][x] == Empty && grid[nextY][x] != South {
					nextGrid[nextY][x] = South
					change = true
				} else {
					nextGrid[y][x] = South
				}
			}
		}

		fmt.Println("step", step)

		if step == -1 {
			for _, row := range nextGrid {
				fmt.Println(row)
			}
			panic("xyz")

		}

		if !change {
			break
		}

		grid = nextGrid
	}

	return
}

func same(a, b [][]Spot) bool {
	for y := 0; y < len(a); y++ {
		for x := 0; x < len(a[0]); x++ {
			if a[y][x] != b[y][x] {
				return false
			}
		}
	}
	return true
}
