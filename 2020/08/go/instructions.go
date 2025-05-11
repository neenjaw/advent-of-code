package main

import (
	"strconv"
	"strings"
)

const inputFilePath = "./input.txt"
const exampleFilePath = "./example.txt"

type Operation int

const (
	Nop Operation = iota + 1
	Jmp
	Acc
)

type Instruction interface {
	Evaluate(p int, acc int) (pNext int, accResult int)
	Type() Operation
	Value() int
}

type NopOp struct {
	pOp int
}

func (n *NopOp) Evaluate(p int, acc int) (pNext int, accResult int) {
	return p + 1, acc
}
func (n *NopOp) Type() Operation {
	return Nop
}
func (n *NopOp) Value() int {
	return n.pOp
}

type AccOp struct {
	accOp int
}

func (a *AccOp) Evaluate(p int, acc int) (pNext int, accResult int) {
	return p + 1, acc + a.accOp
}
func (a *AccOp) Type() Operation {
	return Acc
}
func (a *AccOp) Value() int {
	return a.accOp
}

type JmpOp struct {
	pOp int
}

func (j *JmpOp) Evaluate(p int, acc int) (pNext int, accResult int) {
	return p + j.pOp, acc
}
func (j *JmpOp) Type() Operation {
	return Jmp
}
func (j *JmpOp) Value() int {
	return j.pOp
}

func parseInstruction(line string) Instruction {
	parts := strings.SplitN(line, " ", 2)
	opType := parts[0]
	opValue, _ := strconv.Atoi(parts[1])
	switch opType {
	case "nop":
		return &NopOp{opValue}
	case "jmp":
		return &JmpOp{opValue}
	case "acc":
		return &AccOp{opValue}
	default:
		panic("unhandled op type")
	}

}

func parseInstructions(lines []string) (code []Instruction) {
	code = make([]Instruction, len(lines))

	for i, line := range lines {
		code[i] = parseInstruction(line)
	}
	return
}

func CanInvert(instruction Instruction) bool {
	return instruction.Type() == Nop || instruction.Type() == Jmp
}

func Invert(instruction Instruction) Instruction {
	switch instruction.Type() {
	case Nop:
		return &JmpOp{instruction.Value()}
	case Jmp:
		return &NopOp{instruction.Value()}
	default:
		panic("unhandled inversion")
	}
}
