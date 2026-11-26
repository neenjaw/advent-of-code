package main

import (
	"fmt"
	"os"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) > 1 {
		return fmt.Errorf("usage: go run . [input-file]")
	}

	inputPath := "input.txt"
	if len(args) == 1 {
		inputPath = args[0]
	}

	input, err := os.ReadFile(inputPath)
	if err != nil {
		return fmt.Errorf("read input %q: %w", inputPath, err)
	}

	inputText := string(input)
	fmt.Printf("Part 1: %s\n", part1(inputText))

	if answer, ok := part2(inputText); ok {
		fmt.Printf("Part 2: %s\n", answer)
	}

	return nil
}
