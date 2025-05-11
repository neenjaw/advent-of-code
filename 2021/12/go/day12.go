package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"fmt"
	"log"
	"strings"
)

func main() {
	files := []string{"./example.txt", "./example2.txt", "./example3.txt", "./input.txt"}
	expected := []int{10, 19, 226, 3576}
	expected2 := []int{36, 103, 3509, 84271}
	inputs := make([]string, 0)
	for _, f := range files {
		input, err := file.ReadFile(f)
		if err != nil {
			log.Fatal(err)
			return
		}
		inputs = append(inputs, input)
	}

	for i, input := range inputs {
		fmt.Println(files[i])
		ans, ans2 := run(input)
		if ans != expected[i] {
			fmt.Printf("Unexpected answer for pt1 '%s'. wanted: %v got: %v ", files[i], expected[i], ans)
			return
		}
		if expected2[i] != -1 && ans2 != expected2[i] {
			fmt.Printf("Unexpected answer for pt2 '%s'. wanted: %v got: %v\n", files[i], expected2[i], ans)
			return
		}
		fmt.Println("==========", ans)
		fmt.Println("==========", ans2)
	}

	// answer2 := run(inputLines)
	// log.Printf("Part 2: %v", answer2)
}

type CaveType int

const (
	Big CaveType = iota + 1
	Small
	Start
	End
)

type Cave struct {
	name     rune
	caveType CaveType
}

type Connection struct {
	a, b string
}

type Path []string

func run(input string) (int, int) {
	lines := conv.SplitInputByLine(input)

	connections := map[Connection]bool{}
	caves := map[string]CaveType{"start": Start, "end": End}

	for _, line := range lines {
		parts := strings.SplitN(line, "-", 2)
		a := parts[0]
		b := parts[1]

		addCave(&caves, a)
		addCave(&caves, b)
		addConnection(&connections, a, b)
	}

	connectionIndex := make(map[string]*map[string]bool)
	for connection, _ := range connections {
		if neighbors, ok := connectionIndex[connection.a]; !ok {
			init := map[string]bool{connection.b: true}
			connectionIndex[connection.a] = &init
		} else {
			(*neighbors)[connection.b] = true
		}
	}

	// fmt.Println(caves)
	// fmt.Println("===============")
	// fmt.Println(connections)
	// fmt.Println("===============")

	// for cave, neighours := range connectionIndex {
	// 	fmt.Println(cave, (*neighours))
	// }

	// fmt.Println("===============")

	return dfs(
			caves,
			connections,
			connectionIndex,
			"",
			"start",
			"end",
			map[string]bool{},
			[]string{},
			0,
		), dfsVisitOneTwice(
			caves,
			connections,
			connectionIndex,
			"",
			"start",
			"end",
			map[string]bool{},
			[]string{},
			0,
			false,
		)
}

func addCave(caves *map[string]CaveType, cave string) {
	if _, ok := (*caves)[cave]; !ok {
		switch {
		case cave == "start":
			(*caves)[cave] = Start
		case cave == "end":
			(*caves)[cave] = End
		case cave == strings.ToUpper(cave):
			(*caves)[cave] = Big
		case cave == strings.ToLower(cave):
			(*caves)[cave] = Small
		default:
			panic(fmt.Sprintf("unknown cave type: %v", cave))
		}
	}
}

func addConnection(connections *map[Connection]bool, a string, b string) {
	switch {
	case a == "end" || b == "start":
		(*connections)[Connection{b, a}] = true
	case a == "start" || b == "end":
		(*connections)[Connection{a, b}] = true
	default:
		(*connections)[Connection{a, b}] = true
		(*connections)[Connection{b, a}] = true
	}
}

func dfs(
	caves map[string]CaveType,
	connections map[Connection]bool,
	connectionIndex map[string]*map[string]bool,
	previous string,
	node string,
	goal string,
	visited map[string]bool,
	path []string,
	depth int,
) int {
	path = append(path, node)

	if node == goal {
		// fmt.Print(strings.Repeat("  ", depth))
		// fmt.Printf(">>> goal path: %#v\n", path)
		return 1
	}

	if caves[node] == Small {
		visited[node] = true
	}

	neighbors := connectionIndex[node]

	// fmt.Print(strings.Repeat("  ", depth))
	// fmt.Println(node, *neighbors, previous, visited)

	goals := 0
	for neighbor := range *neighbors {
		if caves[neighbor] == Small && visited[neighbor] {
			continue
		}
		visit_copy := copyVisited(visited)
		goals += dfs(
			caves,
			connections,
			connectionIndex,
			node,
			neighbor,
			goal,
			visit_copy,
			path,
			depth+1,
		)
	}
	return goals
}

func dfsVisitOneTwice(
	caves map[string]CaveType,
	connections map[Connection]bool,
	connectionIndex map[string]*map[string]bool,
	previous string,
	node string,
	goal string,
	visited map[string]bool,
	path []string,
	depth int,
	visited_twice bool,
) int {
	path = append(path, node)

	if node == goal {
		// fmt.Print(strings.Repeat("  ", depth))
		// fmt.Printf(">>> goal path: %#v\n", path)
		return 1
	}

	if caves[node] == Small {
		visited[node] = true
	}

	neighbors := connectionIndex[node]

	// fmt.Print(strings.Repeat("  ", depth))
	// fmt.Println(node, *neighbors, previous, visited)

	goals := 0
	for neighbor := range *neighbors {
		visit_copy := copyVisited(visited)

		next_visit_twice := visited_twice

		if caves[neighbor] == Small {
			if visited[neighbor] && visited_twice {
				continue
			}
			if visited[neighbor] && !visited_twice {
				next_visit_twice = true
			}
		}

		goals += dfsVisitOneTwice(
			caves,
			connections,
			connectionIndex,
			node,
			neighbor,
			goal,
			visit_copy,
			path,
			depth+1,
			next_visit_twice,
		)
	}
	return goals
}

func copyVisited(visited map[string]bool) map[string]bool {
	copy := make(map[string]bool)
	for cave, v := range visited {
		copy[cave] = v
	}
	return copy
}
