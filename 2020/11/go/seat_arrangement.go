package main

import "advent-of-go/util/grid"

type Space int

const (
	EmptySeat Space = iota + 1
	OccupiedSeat
	Floor
)

type Arrangement [][]Space

func ConvInputToSeatingArrangement(input []string) (arr Arrangement) {
	arr = make(Arrangement, len(input))

	for i, line := range input {
		arr[i] = make([]Space, 0, len(line))

		for _, r := range line {
			switch r {
			case '.':
				arr[i] = append(arr[i], Floor)
			case '#':
				arr[i] = append(arr[i], OccupiedSeat)
			case 'L':
				arr[i] = append(arr[i], EmptySeat)
			default:
				panic("unhandled space type")
			}
		}
	}

	return
}

func slopes() []grid.Point {
	return []grid.Point{{1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, 0}, {-1, -1}}
}

func lookaroundSum(arr Arrangement, c grid.Point, limit bool) (sum int) {
	var fx func(Arrangement, grid.Point, grid.Point) bool
	if limit {
		fx = lookImmediate
	} else {
		fx = lookUnlimited
	}

	for _, slope := range slopes() {
		if fx(arr, slope, c) {
			sum += 1
		}
	}

	return
}

func lookImmediate(arr Arrangement, slope grid.Point, c grid.Point) bool {
	minY := 0
	minX := 0
	maxY := len(arr) - 1
	maxX := len(arr[0]) - 1
	c.X += slope.X
	c.Y += slope.Y

	if c.X < minX || c.X > maxX || c.Y < minY || c.Y > maxY {
		return false
	}

	if arr[c.Y][c.X] == OccupiedSeat {
		return true
	}

	return false
}

func lookUnlimited(arr Arrangement, slope grid.Point, c grid.Point) bool {
	minY := 0
	minX := 0
	maxY := len(arr) - 1
	maxX := len(arr[0]) - 1

	for {
		c.X += slope.X
		c.Y += slope.Y

		if c.X < minX || c.X > maxX || c.Y < minY || c.Y > maxY {
			return false
		}

		if arr[c.Y][c.X] == OccupiedSeat {
			return true
		}

		if arr[c.Y][c.X] == EmptySeat {
			return false
		}
	}
}

type StepConfig struct {
	fillThreshold  int
	emptyThreshold int
	limit          bool
}

func Step(arr Arrangement, config StepConfig) (next Arrangement, changed bool) {
	next = make(Arrangement, len(arr))
	for y, row := range arr {
		next[y] = make([]Space, len(row))

		for x, spot := range row {
			if spot == Floor {
				next[y][x] = Floor
				continue
			}

			sum := lookaroundSum(arr, grid.Point{x, y}, config.limit)

			if spot == OccupiedSeat && sum >= config.emptyThreshold {
				next[y][x] = EmptySeat
				changed = true
				continue
			}

			if spot == EmptySeat && sum <= config.fillThreshold {
				next[y][x] = OccupiedSeat
				changed = true
				continue
			}

			next[y][x] = spot
		}
	}
	return
}

func CountOccupied(arr Arrangement) (count int) {
	for _, row := range arr {
		for _, spot := range row {
			if spot == OccupiedSeat {
				count += 1
			}
		}
	}
	return
}
