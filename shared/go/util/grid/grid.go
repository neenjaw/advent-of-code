package grid

import "github.com/adam-lavrik/go-imath/ix"

type Point struct {
	X int
	Y int
}

func (p Point) ManhattanDistance() int {
	return ix.Abs(p.X) + ix.Abs(p.Y)
}

func (p *Point) Translate(dx, dy int) {
	p.X += dx
	p.Y += dy
}
