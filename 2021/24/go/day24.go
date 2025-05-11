package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"strconv"
	"strings"
)

type Limit struct {
	min, max int
}

type Run struct {
	file     string
	target   int
	expected uint64
}

type Input struct {
	idx                int
	div, check, offset int
}

type InstructionType int

const (
	Push InstructionType = iota
	Pop
)

type Instruction struct {
	typeof InstructionType
	offset int
}

func main() {
	runs := []Run{
		{"input.txt", 9, 99911993949684},
		{"input.txt", 1, 62911941716111},
	}

	for i, run := range runs {
		do_main(i, run)
	}
}

func do_main(i int, run Run) uint64 {
	specInput, _ := file.ReadFile(run.file)
	spec := conv.SplitInputByLine(specInput)

	fmt.Println(spec)

	instructions := []Instruction{}
	for i := 0; i < 14; i++ {
		o := i * 18

		fmt.Println(o)
		fmt.Println(o+4, spec[o+4])
		fmt.Println(o+5, spec[o+5])
		fmt.Println(o+15, spec[o+15])

		div, _ := strconv.Atoi(strings.Fields(spec[o+4])[2])
		check, _ := strconv.Atoi(strings.Fields(spec[o+5])[2])
		offset, _ := strconv.Atoi(strings.Fields(spec[o+15])[2])

		input := Input{
			idx:    i,
			div:    div,
			check:  check,
			offset: offset,
		}

		var typeof InstructionType
		if input.check <= 0 {
			typeof = Pop
		} else {
			typeof = Push
		}

		var instructionOffset int
		if typeof == Pop {
			instructionOffset = input.check
		} else {
			instructionOffset = input.offset
		}

		instructions = append(instructions, Instruction{typeof, instructionOffset})
	}

	fmt.Println(inputs)

	return 0
}
