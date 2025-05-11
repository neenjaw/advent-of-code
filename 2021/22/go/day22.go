package main

import (
	"advent-of-go/util/file"
	"advent-of-go/util/mymath"
	"errors"
	"fmt"
)

type Limit struct {
	min, max int
}

type Run struct {
	file     string
	expected int64
	hasLimit bool
	limit    Limit
}

func main() {
	runs := []Run{
		// {"example.txt", 39, true, Limit{-50, 50}},
		// {"example2.txt", 590784, true, Limit{-50, 50}},
		// {"input.txt", 527915, true, Limit{-50, 50}},
	}

	runs2 := []Run{
		{"example3.txt", 2758514936282235, false, Limit{}},
		{"input.txt", 1218645427221987, false, Limit{}},
	}

	for i, run := range runs {
		do_main(i, run)
	}

	for i, run := range runs2 {
		do_main(i, run)
	}
}

func do_main(i int, run Run) {
	fileContent, _ := file.ReadFile(run.file)
	cubeSteps := ParseCuboidSteps(fileContent)

	// fmt.Println(cubeSteps)
	ans := simulate(cubeSteps, run.hasLimit, run.limit)
	if ans != run.expected {
		fmt.Printf("[FAIL] %d: expected: %v got: %v\n", i, run.expected, ans)
		panic("fail")
	} else {
		fmt.Printf("[PASS] %d: expected: %v got: %v\n", i, run.expected, ans)
	}
}

func simulate(steps []Rule, hasLimit bool, limit Limit) int64 {
	cuboids := []Cuboid{}
	for i, step := range steps {
		fmt.Println("STEP >> ", i)
		nextCuboids := []Cuboid{}
		for _, cuboid := range cuboids {
			intersections := cuboid.subtract(step.cuboid)
			nextCuboids = append(nextCuboids, intersections...)
		}

		if step.state == On {
			nextCuboids = append(nextCuboids, step.cuboid)
		}
		cuboids = nextCuboids
	}

	var count int64 = 0
	for _, cuboid := range cuboids {
		count += cuboid.volume()
	}

	return count
}

func (c Cuboid) isProper() bool {
	return c.x0 <= c.x1 && c.y0 <= c.y1 && c.z0 <= c.z1
}

func (c1 Cuboid) intersect(c2 Cuboid) (Cuboid, error) {
	cIntersect := Cuboid{
		x0: mymath.Max(c1.x0, c2.x0),
		x1: mymath.Min(c1.x1, c2.x1),
		y0: mymath.Max(c1.y0, c2.y0),
		y1: mymath.Min(c1.y1, c2.y1),
		z0: mymath.Max(c1.z0, c2.z0),
		z1: mymath.Min(c1.z1, c2.z1),
	}
	if cIntersect.isProper() {
		return cIntersect, nil
	}
	return Cuboid{}, errors.New("improper cuboid")
}

func (c1 Cuboid) subtract(c2 Cuboid) []Cuboid {
	cIntersect, err := c1.intersect(c2)
	if err != nil {
		return []Cuboid{c1}
	}

	if cIntersect == c1 {

		return []Cuboid{}
	}

	cuboids := []Cuboid{}
	if c1.x0 < cIntersect.x0 {
		cx := Cuboid{
			z0: c1.z0,
			z1: c1.z1,
			y0: c1.y0,
			y1: c1.y1,
			x0: c1.x0,
			x1: cIntersect.x0 - 1,
		}
		cuboids = append(cuboids, cx)
	}

	if c1.x1 > cIntersect.x1 {
		cx := Cuboid{
			z0: c1.z0,
			z1: c1.z1,
			y0: c1.y0,
			y1: c1.y1,
			x0: cIntersect.x1 + 1,
			x1: c1.x1,
		}
		cuboids = append(cuboids, cx)
	}

	if c1.y0 < cIntersect.y0 {
		cx := Cuboid{
			z0: c1.z0,
			z1: c1.z1,
			y0: c1.y0,
			y1: cIntersect.y0 - 1,
			x0: cIntersect.x0,
			x1: cIntersect.x1,
		}
		cuboids = append(cuboids, cx)
	}

	if c1.y1 > cIntersect.y1 {
		cx := Cuboid{
			z0: c1.z0,
			z1: c1.z1,
			y0: cIntersect.y1 + 1,
			y1: c1.y1,
			x0: cIntersect.x0,
			x1: cIntersect.x1,
		}
		cuboids = append(cuboids, cx)
	}

	if c1.z0 < cIntersect.z0 {
		cx := Cuboid{
			z0: c1.z0,
			z1: cIntersect.z0 - 1,
			y0: cIntersect.y0,
			y1: cIntersect.y1,
			x0: cIntersect.x0,
			x1: cIntersect.x1,
		}
		cuboids = append(cuboids, cx)
	}

	if c1.z1 > cIntersect.z1 {
		cx := Cuboid{
			z0: cIntersect.z1 + 1,
			z1: c1.z1,
			y0: cIntersect.y0,
			y1: cIntersect.y1,
			x0: cIntersect.x0,
			x1: cIntersect.x1,
		}
		cuboids = append(cuboids, cx)
	}

	return cuboids
}

func (c Cuboid) volume() int64 {
	volume := int64(c.z1-c.z0+1) * int64(c.y1-c.y0+1) * int64(c.x1-c.x0+1)
	return volume
}
