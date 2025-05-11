package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
	"strconv"
	"strings"
)

const inputFilePath = "./input.txt"

type Board struct {
	numbers map[string]bool
	grid    [][]string
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)

	numbers := conv.SplitInputByString(lines[0], ",")
	boards := parseBoards(lines[2:])

	answer1 := Part1(numbers, boards)
	log.Printf("Part 1: %v", answer1)
	answer2 := Part2(numbers, boards)
	log.Printf("Part 2: %v", answer2)
}

func Part1(numbers []string, boards []Board) int {
	var lastNumberCalled int
	var winningBoard Board

out:
	for i, number := range numbers {
		lastNumberCalled = i

		for _, board := range boards {
			board.callNumber(number)
		}

		for _, board := range boards {
			if board.solved() {
				winningBoard = board
				break out
			}
		}
	}

	lastCalledNumber, _ := strconv.Atoi(numbers[lastNumberCalled])
	return lastCalledNumber * winningBoard.uncalledSum()
}

func Part2(numbers []string, boards []Board) int {
	var lastNumberCalled int
	var lastBoardSolved Board

	for i, number := range numbers {
		if len(boards) == 0 {
			break
		}

		lastNumberCalled = i

		for _, board := range boards {
			board.callNumber(number)
		}

		nextBoards := make([]Board, 0)
		for _, board := range boards {
			if board.solved() {
				lastBoardSolved = board
				continue
			}
			nextBoards = append(nextBoards, board)
		}
		boards = nextBoards
	}

	lastCalledNumber, _ := strconv.Atoi(numbers[lastNumberCalled])
	return lastCalledNumber * lastBoardSolved.uncalledSum()
}

func parseBoards(boardInput []string) []Board {
	boards := make([]Board, 0)
	boardRows := make([]string, 0)
	for _, input := range boardInput {
		if input == "" {
			boards = append(boards, makeBoard(boardRows))
			boardRows = make([]string, 0)
			continue
		}

		boardRows = append(boardRows, input)
	}
	boards = append(boards, makeBoard(boardRows))

	return boards
}

func makeBoard(rows []string) Board {
	numbers := make(map[string]bool, 25)
	grid := make([][]string, 5)

	for i, row := range rows {
		rowNumbers := strings.Fields(row)
		for _, rowNumber := range rowNumbers {
			numbers[rowNumber] = false
		}
		grid[i] = rowNumbers
	}

	return Board{grid: grid, numbers: numbers}
}

func (b *Board) callNumber(n string) {
	b.numbers[n] = true
}

func (b *Board) solved() bool {
	for i := 0; i < 5; i++ {
		for j := 0; j < 5; j++ {
			if !b.numbers[b.grid[i][j]] {
				break
			}
			if j == 4 {
				return true
			}
		}
	}
	for i := 0; i < 5; i++ {
		for j := 0; j < 5; j++ {
			if !b.numbers[b.grid[j][i]] {
				break
			}
			if j == 4 {
				return true
			}
		}
	}

	return false
}

func (b *Board) uncalledSum() int {
	sum := 0
	for k, v := range b.numbers {
		if !v {
			intValue, _ := strconv.Atoi(k)
			sum += intValue
		}
	}
	return sum
}
