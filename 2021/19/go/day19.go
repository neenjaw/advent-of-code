package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/enum"
	"advent-of-go/util/file"
	"advent-of-go/util/mymath"
	"fmt"
	"strconv"
	"strings"
)

type Run struct {
	fileName string
	expected int
}

type Point struct {
	x, y, z int
}

type Scanner struct {
	label     int
	beacons   []Point
	distances [][]int64
}

type TransformAxis int

const (
	xAxis TransformAxis = iota
	yAxis
	zAxis
)

type TransformSign int

const (
	Positive TransformSign = 1
	Negative TransformSign = -1
)

type Transform struct {
	axis TransformAxis
	sign TransformSign
}

type Transform3 struct {
	x, y, z Transform
}

type Offset struct {
	axes   Transform3
	offset Point
}

type VisitEntry struct {
	friend, target int
}

type Candidate struct {
	t     int
	point Point
}

var transforms []Transform3
var offsets map[int]Offset

func (p1 Point) distanceFingerprint(p2 Point) int64 {
	return int64((p1.x-p2.x)*(p1.x-p2.x) +
		(p1.y-p2.y)*(p1.y-p2.y) +
		(p1.z-p2.z)*(p1.z-p2.z))
}

func (p1 Point) difference(p2 Point) Point {
	return Point{
		x: p1.x - p2.x,
		y: p1.y - p2.y,
		z: p1.z - p2.z,
	}
}

func (p1 Point) add(p2 Point) Point {
	return Point{
		x: p1.x + p2.x,
		y: p1.y + p2.y,
		z: p1.z + p2.z,
	}
}

func (p1 Point) manhattanDistance(p2 Point) int {
	return mymath.Abs(p1.x-p2.x) +
		mymath.Abs(p1.y-p2.y) +
		mymath.Abs(p1.z-p2.z)
}

func (p Point) transform(t Transform3) Point {
	doTransform := func(p Point, t Transform, v *int) {
		if t.axis == xAxis {
			(*v) = p.x
		} else if t.axis == yAxis {
			(*v) = p.y
		} else if t.axis == zAxis {
			(*v) = p.z
		} else {
			panic("unhandled transform")
		}

		(*v) = (*v) * int(t.sign)
	}

	var x, y, z int
	doTransform(p, t.x, &x)
	doTransform(p, t.y, &y)
	doTransform(p, t.z, &z)
	return Point{x: x, y: y, z: z}
}

func (s1 Scanner) overlappingDistances(s2 Scanner) [][]int {
	d1, d2 := s1.distances, s2.distances
	found := [][]int{}
	for i1, a1 := range d1 {
		for i2, a2 := range d2 {
			if len(enum.Intersection(a1, a2)) >= 12 {
				found = append(found, []int{i1, i2})
			}
		}
	}
	return found
}

func findAllOverlappingDistances(scanners []Scanner) [][][][]int {
	allOverlappingPairs := [][][][]int{}
	for i, s1 := range scanners {
		overlappingPairs := [][][]int{}
		for j, s2 := range scanners {
			if i == j {
				overlappingPairs = append(overlappingPairs, [][]int{})
				continue
			}
			overlappingPairs = append(overlappingPairs, s1.overlappingDistances(s2))
		}
		allOverlappingPairs = append(allOverlappingPairs, overlappingPairs)
	}
	return allOverlappingPairs
}

func findNeighborsFromOverlaps(overlaps [][][][]int) [][]int {
	neighbors := [][]int{}
	for _, c := range overlaps {
		localNeighbors := []int{}
		for idx, os := range c {
			if len(os) >= 12 {
				localNeighbors = append(localNeighbors, idx)
			}
		}
		neighbors = append(neighbors, localNeighbors)
	}
	return neighbors
}

func getInitialToVisit(neighbors [][]int) []VisitEntry {
	toVisit := []VisitEntry{}
	for _, n := range neighbors[0] {
		toVisit = append(toVisit, VisitEntry{0, n})
	}
	return toVisit
}

func parseScanner(label int, input string) Scanner {
	points := make([]Point, 0)
	lines := conv.SplitInputByLine(input)[1:]

	for _, line := range lines {
		ss := strings.Split(line, ",")
		vs := make([]int, 0)
		for _, s := range ss {
			v, _ := strconv.Atoi(s)
			vs = append(vs, v)
		}

		points = append(points, Point{vs[0], vs[1], vs[2]})
	}

	distances := make([][]int64, 0)
	for i, pointA := range points {
		distances = append(distances, make([]int64, 0))
		for _, pointB := range points {
			distance := pointA.distanceFingerprint(pointB)
			distances[i] = append(distances[i], distance)
		}
	}

	return Scanner{label: label, beacons: points, distances: distances}
}

func getAllTransforms() []Transform3 {
	transforms := []Transform3{}

	for _, axisPermutation := range enum.Permutations([]TransformAxis{xAxis, yAxis, zAxis}) {
		signPermutations := [][]TransformSign{
			{1, 1, 1},
			{1, 1, -1},
			{1, -1, 1},
			{1, -1, -1},
			{-1, 1, 1},
			{-1, 1, -1},
			{-1, -1, 1},
			{-1, -1, -1},
		}
		for _, signPermutation := range signPermutations {
			transform := Transform3{
				Transform{axisPermutation[0], signPermutation[0]},
				Transform{axisPermutation[1], signPermutation[1]},
				Transform{axisPermutation[2], signPermutation[2]},
			}
			transforms = append(transforms, transform)
		}
	}

	return transforms
}

func main() {
	runs := []Run{
		{"./example.txt", 79},
		{"./input.txt", 414},
	}

	for _, run := range runs {
		fileContent, _ := file.ReadFile(run.fileName)
		parts := conv.SplitInputByString(fileContent, "\n\n")
		reports := toReports(parts)
		ans, max := countBeacons(reports)
		if ans != run.expected {
			fmt.Printf("[FAIL] %s: expected: %v go: %v", run.fileName, run.expected, ans)
			return
		} else {
			fmt.Printf("[PASS] %s: expected: %v got: %v max: %v", run.fileName, run.expected, ans, max)
		}
	}
}

func toReports(parts []string) (scanners []Scanner) {
	scanners = make([]Scanner, 0)
	for i, part := range parts {
		scanners = append(scanners, parseScanner(i, part))
	}
	return
}

func offsetExists(i int) bool {
	if offsets == nil {
		panic("offsets uninitialized")
	}
	_, ok := offsets[i]
	return ok
}

func initTransforms() {
	transforms = getAllTransforms()
	fmt.Println(transforms)
}

func initOffsets(totalReports int) {
	offsets = make(map[int]Offset)
	offsets[0] = Offset{axes: transforms[0], offset: Point{0, 0, 0}}
}

func countBeacons(scanners []Scanner) (int, int) {
	initTransforms()
	initOffsets(len(scanners))
	allOverlaps := findAllOverlappingDistances(scanners)
	neighbors := findNeighborsFromOverlaps(allOverlaps)

	toVisit := getInitialToVisit(neighbors)
	for len(toVisit) > 0 {
		visit := toVisit[0]
		toVisit = toVisit[1:]

		if offsetExists(visit.target) {
			continue
		}

		friendTransform := offsets[visit.friend].axes
		overlaps := allOverlaps[visit.friend][visit.target]
		candidates := []Candidate{}
		for _, transform := range transforms {
			ds := make([]Point, 0)
			for _, overlap := range overlaps {
				friendL, targetL := overlap[0], overlap[1]
				b1 := scanners[visit.friend].beacons[friendL].transform(friendTransform)
				b2 := scanners[visit.target].beacons[targetL].transform(transform)
				d := b1.difference(b2)
				ds = append(ds, d)
			}

			count := 0
			for _, elt := range ds {
				if elt.x == ds[0].x &&
					elt.y == ds[0].y &&
					elt.z == ds[0].z {
					count += 1
				}
			}

			c := Candidate{count, ds[0]}
			candidates = append(candidates, c)
		}

		var candidateIdx int = -1
		for i, candidate := range candidates {
			if candidate.t == len(overlaps) {
				candidateIdx = i
			}
		}
		if candidateIdx == -1 {
			fmt.Println(visit.friend, visit.target, friendTransform, overlaps)
			panic("fml")
		}

		offsets[visit.target] = Offset{
			axes: transforms[candidateIdx],
			offset: candidates[candidateIdx].point.add(
				offsets[visit.friend].offset,
			),
		}

		for _, neighbor := range neighbors[visit.target] {
			toVisit = append(toVisit, VisitEntry{
				visit.target,
				neighbor,
			})
		}
	}

	allBeacons := make(map[string]bool)
	for i, scanner := range scanners {
		offset := offsets[i]
		for _, beacon := range scanner.beacons {
			adj := beacon.transform(offset.axes).add(offset.offset)
			s := fmt.Sprintf("%v,%v,%v", adj.x, adj.y, adj.z)
			allBeacons[s] = true
		}
	}

	max := 0
	for _, o1 := range offsets {
		for _, o2 := range offsets {
			md := o1.offset.manhattanDistance(o2.offset)
			if md > max {
				max = md
			}
		}
	}

	return len(allBeacons), max
}
