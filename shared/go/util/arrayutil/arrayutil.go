package arrayutil

import (
	"advent-of-go/util/conv"
	"fmt"
	"strconv"
	"strings"
)

type SliceValue interface{}

func SliceBuilder2D(i, j int) [][]SliceValue {
	var slice [][]SliceValue = make([][]SliceValue, i)
	for x := range slice {
		slice[x] = make([]SliceValue, j)
	}
	return slice
}

func SliceBuilder2DString(i, j int) [][]string {
	var slice [][]string = make([][]string, i)
	for x := range slice {
		slice[x] = make([]string, j)
	}
	return slice
}

func SliceBuilder2DInt(i, j int) [][]int {
	var slice [][]int = make([][]int, i)
	for x := range slice {
		slice[x] = make([]int, j)
	}
	return slice
}

func SliceBuilder2DRune(i, j int) [][]rune {
	var slice [][]rune = make([][]rune, i)
	for x := range slice {
		slice[x] = make([]rune, j)
	}
	return slice
}

func SPrintArrayYX(array interface{}, format string) string {
	out := ""
	switch arr := array.(type) {
	case [][]string:
		for x := range arr {
			for y := range arr[0] {
				out += fmt.Sprintf(format+" ", arr[x][y])
			}
			out += "\n"
		}
	case [][]int:
		for x := range arr {
			for y := range arr[0] {
				out += fmt.Sprintf(format+" ", arr[x][y])
			}
			out += "\n"
		}
	case [][]rune:
		for x := range arr {
			for y := range arr[0] {
				out += fmt.Sprintf(format+" ", arr[x][y])
			}
			out += "\n"
		}
	}
	return out
}

func SPrintArrayXY(array interface{}, format string) string {
	out := ""
	switch arr := array.(type) {
	case [][]string:
		for x := range arr[0] {
			for y := range arr {
				out += fmt.Sprintf(format+" ", arr[y][x])
			}
			out += "\n"
		}
	case [][]int:
		for x := range arr[0] {
			for y := range arr {
				out += fmt.Sprintf(format+" ", arr[y][x])
			}
			out += "\n"
		}
	case [][]rune:
		for x := range arr[0] {
			for y := range arr {
				out += fmt.Sprintf(format+" ", arr[y][x])
			}
			out += "\n"
		}
	}
	return out
}

func Dynamic2DStringSliceBuilder(
	input string,
	line_delimiter string,
	cell_delimiter string,
) [][]string {
	lines := conv.SplitInputByString(input, line_delimiter)
	grid := make([][]string, 0)
	for i, line := range lines {
		grid = append(grid, make([]string, 0))
		cells := strings.Split(line, cell_delimiter)
		grid[i] = append(grid[i], cells...)
	}
	return grid
}

func Dynamic2DRuneSliceBuilder(
	input string,
	line_delimiter string,
	cell_delimiter string,
) [][]rune {
	lines := conv.SplitInputByString(input, line_delimiter)
	grid := make([][]rune, 0)
	for i, line := range lines {
		grid = append(grid, make([]rune, 0))
		for _, r := range line {
			grid[i] = append(grid[i], r)
		}
	}
	return grid
}

func Dynamic2DIntSliceBuilder(
	input string,
	line_delimiter string,
	cell_delimiter string,
) [][]int {
	lines := conv.SplitInputByString(input, line_delimiter)
	grid := make([][]int, 0)
	for i, line := range lines {
		grid = append(grid, make([]int, 0))
		cells := strings.Split(line, cell_delimiter)
		for _, cell := range cells {
			v, err := strconv.Atoi(cell)
			if err != nil {
				panic(err)
			}
			grid[i] = append(grid[i], v)
		}
	}
	return grid
}
