package main

import (
	"advent-of-go/util/arrayutil"
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"log"
	"strconv"
	"strings"
)

func main() {
	files := []string{"./example.txt", "./input.txt"}
	expected := []int{17, 781}

	inputs := make([]string, 0)
	for _, f := range files {
		input, err := file.ReadFile(f)
		if err != nil {
			log.Fatal(err)
			return
		}
		inputs = append(inputs, input)
	}

	for i, input := range inputs {
		fmt.Println(files[i])
		parts := conv.SplitInputByString(input, "\n\n")
		dots := conv.SplitInputByLine(parts[0])
		instructions := conv.SplitInputByLine(parts[1])

		ans, _ := run(dots, instructions)
		if ans != expected[i] {
			fmt.Printf("Unexpected answer for pt1 '%s'. wanted: %v got: %v ", files[i], expected[i], ans)
			return
		}
		fmt.Println("P1 ==========", ans)
	}
}

func run(dot_input []string, instructions []string) (int, int) {
	grid := make_grid(dot_input)
	var first_fold_count int
	var final_fold_count int

	for _, instruction := range instructions {
		small := instruction[11:]
		parts := strings.SplitN(small, "=", 2)
		fold_direction := conv.FirstRune(parts[0])
		fold_value, _ := strconv.Atoi(parts[1])

		if fold_direction == 'y' {
			fold_horizontal(&grid, fold_value)
		} else if fold_direction == 'x' {
			fold_vertical(&grid, fold_value)
		} else {
			panic("unknown")
		}

		if first_fold_count == 0 {
			first_fold_count = count(grid)
		}
	}

	print_out(grid)

	return first_fold_count, final_fold_count
}

func fold_horizontal(grid *[][]rune, y int) {
	for i := 0; i < len((*grid)[y]); i++ {
		(*grid)[y][i] = '.'
	}

	for i := y + 1; i < len(*grid); i++ {
		difference := abs(i - y)
		for j := 0; j < len((*grid)[i]); j++ {
			if (*grid)[i][j] == '#' {
				(*grid)[i][j] = '.'
				(*grid)[y-difference][j] = '#'
			}
		}
	}

	(*grid) = (*grid)[0:y]
}

func fold_vertical(grid *[][]rune, target int) {
	for i := 0; i < len(*grid); i++ {
		(*grid)[i][target] = '.'
	}

	for x := target + 1; x < len((*grid)[0]); x++ {
		difference := abs(x - target)
		for y := 0; y < len(*grid); y++ {
			if (*grid)[y][x] == '#' {
				(*grid)[y][x] = '.'
				(*grid)[y][x-2*difference] = '#'
			}
		}
	}

	for y := range *grid {
		(*grid)[y] = (*grid)[y][0:target]
	}
}

func count(grid [][]rune) (count int) {
	for _, row := range grid {
		for _, v := range row {
			if v == '#' {
				count += 1
			}
		}
	}
	return
}

func print_out(grid [][]rune) {
	for _, row := range grid {
		for _, v := range row {
			fmt.Printf("%c", v)
		}
		println()
	}
}

type Dot struct {
	x, y int
}

func make_grid(dot_inputs []string) [][]rune {
	max_x := 0
	max_y := 0
	dots := make([]Dot, 0)
	for _, dot_input := range dot_inputs {
		parts := strings.SplitN(dot_input, ",", 2)
		x, _ := strconv.Atoi(parts[0])
		y, _ := strconv.Atoi(parts[1])

		if x > max_x {
			max_x = x
		}
		if y > max_y {
			max_y = y
		}

		dots = append(dots, Dot{x, y})
	}

	// fmt.Printf("%v", dots)

	grid := arrayutil.SliceBuilder2DRune(max_y+1, max_x+1)

	for _, dot := range dots {
		grid[dot.y][dot.x] = '#'
	}

	for y, row := range grid {
		for x, v := range row {
			if v == '#' {
				continue
			}
			grid[y][x] = '.'
		}
	}

	return grid
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}
