package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"log"
)

const inputFilePath = "./input.txt"

type Terrain int

const (
	BareGround Terrain = iota + 1
	Tree
)

func parseLineToTerrain(line string) []Terrain {
	tiles := []rune(line)
	terrainTiles := make([]Terrain, 0, len(tiles))

	for _, tile := range tiles {
		if tile == '.' {
			terrainTiles = append(terrainTiles, BareGround)
		} else {
			terrainTiles = append(terrainTiles, Tree)
		}
	}

	return terrainTiles
}

func parseLinesToTerrain(lines []string) [][]Terrain {
	terrain := make([][]Terrain, 0, len(lines))
	for _, line := range lines {
		terrain = append(terrain, parseLineToTerrain(line))
	}
	return terrain
}

type Slope struct {
	dx int
	dy int
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	lines := conv.SplitInputByLine(input)
	terrain := parseLinesToTerrain(lines)

	singleSlope := []Slope{{3, 1}}
	answer1 := ComputeMaxTreesEncountered(terrain, singleSlope)
	log.Printf("Part 1: %v", answer1)

	multipleSlopes := []Slope{{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}}
	answer2 := ComputeMaxTreesEncountered(terrain, multipleSlopes)
	log.Printf("Part 2: %v", answer2)
}

func ComputeMaxTreesEncountered(terrain [][]Terrain, slopes []Slope) int {
	treeProduct := 1
	terrainHeight := len(terrain)
	terrainWidth := len(terrain[0])

	for _, slope := range slopes {
		treesEncountered, x, y := 0, 0, 0

		for {
			tile := terrain[y][x]
			if tile == Tree {
				treesEncountered += 1
			}

			x += slope.dx
			x = x % terrainWidth

			y += slope.dy
			if y >= terrainHeight {
				break
			}
		}

		treeProduct *= treesEncountered
	}

	return treeProduct
}
