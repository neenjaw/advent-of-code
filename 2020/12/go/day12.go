package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"advent-of-go/util/grid"
	"log"
	"math"
	"strconv"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"

type InstructionType int

const (
	MoveN     InstructionType = 'N'
	MoveS     InstructionType = 'S'
	MoveE     InstructionType = 'E'
	MoveW     InstructionType = 'W'
	TurnLeft  InstructionType = 'L'
	TurnRight InstructionType = 'R'
	Forward   InstructionType = 'F'
)

type Instruction struct {
	action InstructionType
	value  int
}

type Direction int

const (
	N Direction = 90
	S Direction = 270
	E Direction = 0
	W Direction = 180
)

func SplitLineToInstruction(line string) Instruction {
	rs := []rune(line)
	value, _ := strconv.Atoi(string(rs[1:]))
	return Instruction{action: InstructionType(rs[0]), value: value}
}

func SplitLinesToInstruction(lines []string) (ins []Instruction) {
	ins = make([]Instruction, len(lines))
	for i, line := range lines {
		ins[i] = SplitLineToInstruction(line)
	}
	return
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)
	instructions := SplitLinesToInstruction(lines)

	answer1 := part1(instructions)
	log.Printf("Part 1: %v", answer1)

	answer2 := part2(instructions)
	log.Printf("Part 2: %v", answer2)
}

func part1(instructions []Instruction) int {
	ship := grid.Point{0, 0}
	direction := E

	for _, instruction := range instructions {
		switch instruction.action {
		case MoveN:
			moveShip(&ship, N, instruction.value)
		case MoveE:
			moveShip(&ship, E, instruction.value)
		case MoveS:
			moveShip(&ship, S, instruction.value)
		case MoveW:
			moveShip(&ship, W, instruction.value)
		case TurnLeft:
			direction = rotate(direction, instruction.value)
		case TurnRight:
			direction = rotate(direction, -instruction.value)
		case Forward:
			moveShip(&ship, direction, instruction.value)
		default:
			panic("unhandled")
		}
	}

	return ship.ManhattanDistance()
}

func moveShip(ship *grid.Point, direction Direction, amount int) {
	switch direction {
	case N:
		ship.Translate(0, amount)
	case S:
		ship.Translate(0, -amount)
	case E:
		ship.Translate(amount, 0)
	case W:
		ship.Translate(-amount, 0)
	}
}

func rotate(d Direction, amount int) Direction {
	degrees := int(d) + amount
	degrees %= 360
	if degrees < 0 {
		degrees += 360
	}
	return Direction(degrees)
}

func part2(instructions []Instruction) int {
	ship := grid.Point{0, 0}
	waypoint := grid.Point{10, 1}

	for _, instruction := range instructions {
		switch instruction.action {
		case MoveN:
			moveShip(&waypoint, N, instruction.value)
		case MoveE:
			moveShip(&waypoint, E, instruction.value)
		case MoveS:
			moveShip(&waypoint, S, instruction.value)
		case MoveW:
			moveShip(&waypoint, W, instruction.value)
		case TurnLeft:
			rotateWaypoint(&waypoint, instruction.value)
		case TurnRight:
			rotateWaypoint(&waypoint, -instruction.value)
		case Forward:
			moveShipToWaypoint(&ship, waypoint, instruction.value)
		default:
			panic("unhandled")
		}
	}

	return ship.ManhattanDistance()
}

func rotateWaypoint(waypoint *grid.Point, degrees int) {
	radians := float64(degrees) * math.Pi / 180
	cos := int(math.Cos(radians))
	sin := int(math.Sin(radians))
	rotatedX := waypoint.X*cos - waypoint.Y*sin
	rotatedY := waypoint.X*sin + waypoint.Y*cos

	waypoint.X = rotatedX
	waypoint.Y = rotatedY
}

func moveShipToWaypoint(ship *grid.Point, waypoint grid.Point, times int) {
	for i := 0; i < times; i++ {
		ship.X += waypoint.X
		ship.Y += waypoint.Y
	}
}
