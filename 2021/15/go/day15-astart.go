package main

import (
	"advent-of-go/util/arrayutil"
	"advent-of-go/util/file"
	"fmt"
	"log"
	"math"

	astar "github.com/beefsack/go-astar"
)

type Pos struct {
	y, x int
}

type Grid struct {
	grid                     [][]int
	dimX, dimY               int
	virtualDimX, virtualDimY int
}

func (g *Grid) getCostAtPos(p Pos) int {
	yGrid, xGrid := 0, 0
	for p.y > g.dimY+(g.dimY*yGrid)-1 {
		yGrid++
	}
	for p.x > g.dimX+(g.dimX*xGrid)-1 {
		xGrid++
	}
	shift := yGrid + xGrid
	cost := g.grid[p.y%g.dimY][p.x%g.dimX]
	for i := 0; i < shift; i++ {
		cost += 1
		if cost > 9 {
			cost = 1
		}
	}

	return cost
}

type Tile struct {
	position Pos
	grid     *Grid
}

var tileMap map[Pos]*Tile

func (t *Tile) validPosition(p Pos) bool {
	return !(p.y < 0 ||
		p.y >= t.grid.virtualDimY ||
		p.x < 0 ||
		p.x >= t.grid.virtualDimX)
}

func (t *Tile) PathNeighbors() []astar.Pather {
	var neighbors []astar.Pather = make([]astar.Pather, 0)

	for _, d := range []Pos{{1, 0}, {-1, 0}, {0, 1}, {0, -1}} {
		neighborPosition := Pos{x: (*t).position.x + d.x, y: (*t).position.y + d.y}

		if t.validPosition(neighborPosition) {
			var neighborTile *Tile
			if tile, ok := tileMap[neighborPosition]; ok {
				neighborTile = tile
			} else {
				neighborTile = &Tile{position: neighborPosition, grid: t.grid}
				tileMap[neighborPosition] = neighborTile
			}

			neighbors = append(neighbors, neighborTile)
		}
	}
	return neighbors
}

func (t *Tile) PathNeighborCost(to astar.Pather) (cost float64) {
	cost = float64(((*(to.(*Tile))).grid).getCostAtPos((*(to.(*Tile))).position))
	return
}

func (t *Tile) PathEstimatedCost(to astar.Pather) float64 {
	toTile := to.(*Tile)
	x := math.Abs(float64(toTile.position.x - t.position.x))
	y := math.Abs(float64(toTile.position.y - t.position.y))
	return x + y
}

func main() {
	files := []string{"./example.txt", "./input.txt"}
	expected := []int{40, 602}
	expected2 := []int{315, 2935}

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

		ans := run(input, 1, 1)
		if ans != float64(expected[i]) {
			fmt.Printf("Unexpected answer for pt1 '%s'. wanted: %v got: %v ", files[i], expected[i], ans)
			return
		}
		fmt.Println("P1 ==========", ans)
	}

	for i, input := range inputs {
		fmt.Println(files[i])

		ans := run(input, 5, 5)
		if ans != float64(expected2[i]) {
			fmt.Printf("Unexpected answer for pt2 '%s'. wanted: %v got: %v ", files[i], expected2[i], ans)
			return
		}
		fmt.Println("P2 ==========", ans)
	}
}

func run(input string, mx, my int) float64 {
	tileMap = make(map[Pos]*Tile)
	costGrid := arrayutil.Dynamic2DIntSliceBuilder(input, "\n", "")
	grid := Grid{
		grid:        costGrid,
		dimX:        len(costGrid[0]),
		dimY:        len(costGrid),
		virtualDimX: len(costGrid[0]) * mx,
		virtualDimY: len(costGrid) * my,
	}
	start := Tile{
		position: Pos{0, 0},
		grid:     &grid,
	}
	end := Tile{
		position: Pos{y: grid.virtualDimY - 1, x: grid.virtualDimX - 1},
		grid:     &grid,
	}

	tileMap[Pos{0, 0}] = &start
	tileMap[Pos{y: grid.virtualDimY - 1, x: grid.virtualDimX - 1}] = &end

	path, distance, found := astar.Path(&start, &end)

	fmt.Println(path, distance, found)

	return distance
}
