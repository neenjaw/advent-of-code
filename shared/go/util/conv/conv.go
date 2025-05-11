package conv

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
)

// Takes a string, creates a slice of integers
func ConvInputToIntegers(input string) ([]int, error) {
	lines := SplitInputByLine(input)
	integers := make([]int, 0, len(lines))

	for _, line := range lines {
		integer, err := strconv.Atoi(line)

		if err != nil {
			return nil, errors.New(fmt.Sprintf("'%s' is not a numeric string", line))
		}

		integers = append(integers, integer)
	}

	return integers, nil
}

func SplitInputByString(input string, splitter string) []string {
	return strings.Split(strings.TrimSpace(input), splitter)
}

func SplitInputByLine(input string) []string {
	return SplitInputByString(input, "\n")
}

func FirstRune(str string) (r rune) {
	for _, r = range str {
		return
	}
	return
}
