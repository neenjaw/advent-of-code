package main

import (
	"fmt"
	"math"
)

type Range struct {
	start, end int
}

type Goal struct {
	x, y Range
}

func main() {
	inputs := []Goal{
		{Range{20, 30}, Range{-10, -5}},
		{Range{265, 287}, Range{-103, -58}},
	}

	expected := []int{45, 5253}

	for i, input := range inputs {
		ans := run(input)
		if ans != expected[i] {
			fmt.Printf("Unexpected answer for pt1 #'%v'. wanted: %v got: %v ", i, expected[i], ans)
			return
		}
		fmt.Println("P1 ==========", ans)
	}
}

func run(input Goal) int {
	xs := find_min_xs(input.x)
	fmt.Println(xs)

	sxs := find_any_xs(input.x)
	fmt.Println(sxs)
	return find_max_y(sxs, input.x, input.y)
}

func find_min_xs(r Range) []int {
	xs := make([]int, 0)
	x := 1
	for {
		gsum := geometric_series_sum(x)
		if gsum < r.start {
			x++
			continue
		}
		if gsum > r.end {
			break
		}
		xs = append(xs, x)
		x++
	}

	return xs
}

func find_any_xs(r Range) []int {
	xs := make([]int, 0)

	vs := make([]bool, r.end)
outer:
	for x_start := range vs {
		x_start += 1
		x := x_start
		xpos := 0
		for {
			if x == 0 {
				continue outer
			}

			if xpos < r.start {
				xpos += x
				x -= 1
				continue
			}
			if xpos >= r.start && xpos <= r.end {
				xs = append(xs, x_start)
			}
			continue outer
		}
	}
	return xs
}

type Key struct {
	y, x int
}

func find_max_y(xs []int, rx Range, ry Range) int {
	max_y := 0
	distinct := make(map[Key]bool)

	for _, x := range xs {
		y := simulate(x, rx, ry, &distinct)
		if y > max_y {
			max_y = y
		}
	}

	fmt.Println(len(distinct))
	return max_y
}

func simulate(xv int, rx Range, ry Range, d *map[Key]bool) int {
	max_y_height := math.MinInt
	y_start := -10000

outer:
	for {
		if y_start > 10000 {
			break
		}

		x, y := 0, 0
		x_velocity, y_velocity := xv, y_start
		run_y_max := 0

		for {
			if (y < ry.start && y_velocity < 0) ||
				(x < rx.start && x_velocity < 1) ||
				x > rx.end {
				y_start++
				continue outer
			} else if y >= ry.start && y <= ry.end && x >= rx.start && x <= rx.end {
				(*d)[Key{x: xv, y: y_start}] = true
				if run_y_max > max_y_height {
					max_y_height = run_y_max
				}
				y_start++
				continue outer
			}

			y += y_velocity
			x += x_velocity
			y_velocity -= 1
			if x_velocity > 0 {
				x_velocity -= 1
			}

			if y > run_y_max {
				run_y_max = y
			}
		}
	}

	return max_y_height
}

func geometric_series_sum(n int) int {
	return (n * (n + 1)) / 2
}
