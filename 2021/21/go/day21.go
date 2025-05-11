package main

import (
	"advent-of-go/util/enum"
	"fmt"
)

type StartingPosition struct {
	player, position int
}

type Run struct {
	size              int
	startingPositions []StartingPosition
	expected          uint64
}

type QuantileDice int

type Pair struct {
	sum    int
	occurs uint64
}

// roll3 returns a list of Pair, one for each sum of the 3 dice, and how many
// permutations can arrive at that sum
func (q QuantileDice) roll3() []Pair {
	return []Pair{
		{3, 1}, // 111
		{4, 3}, // 112, 121, 211
		{5, 6}, // 221, 122, 212, 113, 311, 131
		{6, 7}, // 222, 123, 132, 312, 321, 213, 231
		{7, 6}, // 223, 232, 322, 331, 313, 133
		{8, 3}, // 332, 323, 233
		{9, 1}, // 333
	}
}

type GameState struct {
	p1Score   int
	p2Score   int
	p1Pos     int
	p2Pos     int
	universes uint64
}

type GameHash struct {
	p1Score int
	p2Score int
	p1Pos   int
	p2Pos   int
}

type DeterministicDice int

var dice DeterministicDice
var qDice QuantileDice

func (d DeterministicDice) roll3() []int {
	rolls := []int{}
	for i := 0; i < 3; i++ {
		rolls = append(rolls, d.roll())
	}
	return rolls
}

func (d DeterministicDice) roll() int {
	dice += 1
	if dice > 100 {
		dice = 1
	}
	return int(dice)
}

func main() {
	runs := []Run{
		{10, []StartingPosition{{1, 3}, {2, 7}}, 739785},
		{10, []StartingPosition{{1, 0}, {2, 2}}, 897798},
	}

	runs2 := []Run{
		{10, []StartingPosition{{1, 3}, {2, 7}}, 444356092776315},
		{10, []StartingPosition{{1, 0}, {2, 2}}, 48868319769358},
	}

	for i, run := range runs {
		ans := game(run.size, run.startingPositions)
		if uint64(ans) != run.expected {
			fmt.Printf("[FAIL] %d: expected: %v go: %v\n", i, run.expected, ans)
			return
		} else {
			fmt.Printf("[PASS] %d: expected: %v got: %v\n", i, run.expected, ans)
		}
	}

	for i, run := range runs2 {
		ans := quantumGame(run.size, run.startingPositions)
		if ans != run.expected {
			fmt.Printf("[FAIL] %d: expected: %v go: %v\n", i, run.expected, ans)
			return
		} else {
			fmt.Printf("[PASS] %d: expected: %v got: %v\n", i, run.expected, ans)
		}
	}
}

type TurnOrder []int

func (t *TurnOrder) turn() int {
	turn := (*t)[0]
	(*t) = (*t)[1:]
	(*t) = append((*t), turn)
	return turn
}

func game(boardSize int, startingPositions []StartingPosition) int {
	dice = 0
	positions := map[int]int{}
	for _, sp := range startingPositions {
		positions[sp.player] = sp.position
	}

	turnOrder := TurnOrder{1, 2}
	points := map[int]int{}
	rollCount := 0
	var player int

	for !existsWinner(&points) {
		player = turnOrder.turn()
		rolls := dice.roll3()

		move := enum.Sum(rolls)

		lastPos := positions[player]
		nextPos := (lastPos + move) % boardSize
		positions[player] = nextPos
		points[player] += positions[player] + 1

		rollCount += len(rolls)
	}

	loser := turnOrder.turn()
	point := points[loser]

	fmt.Println(points)
	fmt.Println(positions)

	fmt.Println(loser, point, rollCount)

	return point * rollCount
}

func existsWinner(points *map[int]int) bool {
	for _, point := range *points {
		if point >= 1000 {
			return true
		}
	}
	return false
}

func quantumGame(size int, sps []StartingPosition) uint64 {
	gameLookup := map[GameHash]GameState{
		{
			p1Score: 0,
			p2Score: 0,
			p1Pos:   sps[0].position,
			p2Pos:   sps[1].position,
		}: {
			p1Score:   0,
			p2Score:   0,
			p1Pos:     sps[0].position,
			p2Pos:     sps[1].position,
			universes: 1,
		},
	}

	finishedGames := []GameState{}

	turnOrder := TurnOrder{1, 2}
	for len(gameLookup) > 0 {
		nextGames := []GameState{}
		player := turnOrder.turn()

		for _, gameState := range gameLookup {
			for _, rollCombination := range qDice.roll3() {
				moves := rollCombination.sum

				var p1Pos, p2Pos, p1Score, p2Score int
				if player == 1 {
					p1LastPos := gameState.p1Pos
					p1NextPos := (p1LastPos + moves) % 10
					p1Pos = p1NextPos
					p1Score = gameState.p1Score + p1Pos + 1

					p2Pos = gameState.p2Pos
					p2Score = gameState.p2Score
				} else if player == 2 {
					p2LastPos := gameState.p2Pos
					p2NextPos := (p2LastPos + moves) % 10
					p2Pos = p2NextPos
					p2Score = gameState.p2Score + p2Pos + 1

					p1Pos = gameState.p1Pos
					p1Score = gameState.p1Score
				} else {
					panic("which player?!?!?")
				}

				game := GameState{
					p1Score:   p1Score,
					p2Score:   p2Score,
					p1Pos:     p1Pos,
					p2Pos:     p2Pos,
					universes: gameState.universes * rollCombination.occurs,
				}

				if game.p1Score >= 21 || game.p2Score >= 21 {
					finishedGames = append(finishedGames, game)
				} else {
					nextGames = append(nextGames, game)
				}
			}
		}

		nextGameLookUp := map[GameHash]GameState{}
		for _, game := range nextGames {
			hash := GameHash{
				p1Score: game.p1Score,
				p2Score: game.p2Score,
				p1Pos:   game.p1Pos,
				p2Pos:   game.p2Pos,
			}

			if hashedGame, ok := nextGameLookUp[hash]; ok {
				hashedGame.universes += game.universes
				nextGameLookUp[hash] = hashedGame
			} else {
				nextGameLookUp[hash] = game
			}
		}
		gameLookup = nextGameLookUp

		fmt.Println(len(finishedGames), len(gameLookup))
	}

	var p1Count uint64 = 0
	var p2Count uint64 = 0
	for _, game := range finishedGames {
		if game.p1Score >= 21 {
			p1Count += game.universes
		}
		if game.p2Score >= 21 {
			p2Count += game.universes
		}
	}

	if p1Count >= p2Count {
		return p1Count
	} else {
		return p2Count
	}
}
