package main

import (
	"advent-of-go/util/arrayutil"
	"advent-of-go/util/file"
	"errors"
	"fmt"
	"log"
	"math"
)

func main() {
	files := []string{"./example.txt", "./input.txt"}
	expected := []int{40, 602}
	expected2 := []int{315, 0}

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

		ans := run(input)
		if ans != expected[i] {
			fmt.Printf("Unexpected answer for pt1 '%s'. wanted: %v got: %v ", files[i], expected[i], ans)
			return
		}
		fmt.Println("P1 ==========", ans)
	}

	for i, input := range inputs {
		fmt.Println(files[i])

		ans := runAStar(input)
		if ans != expected2[i] {
			fmt.Printf("Unexpected answer for pt2 '%s'. wanted: %v got: %v ", files[i], expected2[i], ans)
			return
		}
		fmt.Println("P2 ==========", ans)
	}
}

type Pos struct {
	y, x int
}

type CostMap map[Pos]int

type Grid [][]int

func run(input string) int {
	grid := arrayutil.Dynamic2DIntSliceBuilder(input, "\n", "")

	initCosts := CostMap(make(map[Pos]int))
	return dynamicMinCost(grid, Pos{len(grid) - 1, len(grid[0]) - 1}, &initCosts)
}

func run2(input string) int {
	grid := Grid(arrayutil.Dynamic2DIntSliceBuilder(input, "\n", ""))

	initCosts := CostMap(make(map[Pos]int))
	return dynamicMinCost(grid, Pos{len(grid)*5 - 1, len(grid[0])*5 - 1}, &initCosts)
}

func runAStar(input string) int {
	return 0
}

// naive
// func minCost(grid [][]int, goal Pos) (cost int) {
// 	if goal.y < 0 || goal.x < 0 {
// 		return math.MaxInt
// 	} else if goal.y == 0 && goal.x == 0 {
// 		return 0
// 	} else {
// 		return grid[goal.y][goal.x] + minInt([]int{
// 			minCost(grid, Pos{x: goal.x - 1, y: goal.y}),
// 			minCost(grid, Pos{x: goal.x, y: goal.y - 1}),
// 		})
// 	}
// }

func (g Grid) getCostAtPos(p Pos) int {

	yGrid, xGrid := 0, 0
	for p.y > len(g)+(len(g)*yGrid)-1 {
		yGrid++
	}
	for p.x > len(g[0])+(len(g[0])*xGrid)-1 {
		xGrid++
	}
	shift := yGrid + xGrid
	cost := g[p.y%len(g)][p.x%len(g[0])]
	for i := 0; i < shift; i++ {
		cost += 1
		if cost > 9 {
			cost = 1
		}
	}

	return cost
}

func minInt(ints []int) int {
	min := math.MaxInt
	for _, i := range ints {
		if i < min {
			min = i
		}
	}
	return min
}

func dynamicMinCost(grid Grid, goal Pos, costs *CostMap) int {
	if goal.y < 0 || goal.x < 0 {
		return math.MaxInt
	} else if goal.y == 0 && goal.x == 0 {
		return 0
	} else {
		upAncestorCost, err := costs.getCost(Pos{x: goal.x - 1, y: goal.y})
		if err != nil {
			upAncestorCost = dynamicMinCost(grid, Pos{x: goal.x - 1, y: goal.y}, costs)
		}
		leftAncestorCost, err := costs.getCost(Pos{x: goal.x, y: goal.y - 1})
		if err != nil {
			leftAncestorCost = dynamicMinCost(grid, Pos{x: goal.x, y: goal.y - 1}, costs)
		}

		partCost := grid.getCostAtPos(goal) + minInt([]int{
			upAncestorCost,
			leftAncestorCost,
		})
		costs.setCost(goal, partCost)
		return partCost
	}
}

func (c *CostMap) getCost(p Pos) (int, error) {
	if v, ok := (*c)[p]; !ok {
		return 0, errors.New("not found yet")
	} else {
		return v, nil
	}
}

func (c *CostMap) setCost(p Pos, cost int) {
	(*c)[p] = cost
}
