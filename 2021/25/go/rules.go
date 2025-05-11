package main

import (
	"advent-of-go/util/conv"
	"fmt"
	"strconv"
	"strings"
)

type Cuboid struct {
	z1, z2, y1, y2, x1, x2 int
	subtractions           map[Position]bool
}

type State int

const (
	On  State = 1
	Off State = 0
)

type Rule struct {
	state  State
	cuboid Cuboid
}

func ParseCuboidSteps(input string) []Rule {
	steps := conv.SplitInputByLine(input)
	parsed := []Rule{}
	for _, step := range steps {
		parts := strings.SplitN(step, " ", 2)
		state := parseState(parts[0])

		coords := strings.SplitN(parts[1], ",", 3)
		var x1, x2, y1, y2, z1, z2 int
		for _, coord := range coords {
			components := strings.SplitN(coord, "=", 2)
			domain := strings.SplitN(components[1], "..", 2)
			d1, _ := strconv.Atoi(domain[0])
			d2, _ := strconv.Atoi(domain[1])

			if d2 < d1 {
				panic("unhandled, expects smaller coordinate on left")
			}

			switch components[0] {
			case "x":
				x1 = d1
				x2 = d2
			case "y":
				y1 = d1
				y2 = d2
			case "z":
				z1 = d1
				z2 = d2
			}
		}

		rule := Rule{
			state: state,
			cuboid: Cuboid{
				x1:           x1,
				x2:           x2,
				y1:           y1,
				y2:           y2,
				z1:           z1,
				z2:           z2,
				subtractions: make(map[Position]bool),
			},
		}
		parsed = append(parsed, rule)
	}
	return parsed
}

func parseState(s string) State {
	if s == "on" {
		return On
	} else if s == "off" {
		return Off
	}
	panic(fmt.Sprintf("unhandled state: %s\n", s))
}
