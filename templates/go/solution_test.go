package main

import (
	"os"
	"testing"
)

func readSample(t *testing.T, path string) string {
	t.Helper()

	input, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read sample %q: %v", path, err)
	}

	return string(input)
}

func TestPart1Sample(t *testing.T) {
	input := readSample(t, "samples/part1.txt")
	if got, want := part1(input), "3"; got != want {
		t.Errorf("part1() = %q, want %q", got, want)
	}
}

func TestPart2Sample(t *testing.T) {
	input := readSample(t, "samples/part2.txt")
	if got, ok := part2(input); !ok || got != "10" {
		t.Errorf("part2() = (%q, %t), want (%q, true)", got, ok, "10")
	}
}
