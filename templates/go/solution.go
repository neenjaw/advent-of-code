package main

import (
	"strconv"
	"strings"
)

func part1(input string) string {
	if input == "" {
		return "0"
	}

	lines := strings.Split(input, "\n")
	if lines[len(lines)-1] == "" {
		lines = lines[:len(lines)-1]
	}

	return strconv.Itoa(len(lines))
}

func part2(input string) (string, bool) {
	return strconv.Itoa(len(input)), true
}
