package enum

import (
	"errors"
	"math"
)

func EveryString(slice []string, fn func(string) bool) bool {
	result := true
	for _, s := range slice {
		result = result && fn(s)
	}
	return result
}

func MaxByIntValue(values []int) (int, int) {
	maxIndex, maxValue := -1, math.MinInt
	for i, value := range values {
		if value > maxValue {
			maxIndex = i
			maxValue = value
		}
	}
	return maxIndex, maxValue
}

func Sum(values []int) (sum int) {
	for _, v := range values {
		sum += v
	}
	return
}

func ContainsInt(haystack []int, needle int) bool {
	for _, item := range haystack {
		if item == needle {
			return true
		}
	}
	return false
}

func Find(haystack []string, compare func(needle string) bool) (string, error) {
	for _, item := range haystack {
		if compare(item) {
			return item, nil
		}
	}
	return "", errors.New("nothing found with comparator")
}

func Permutations[T any](slice []T) [][]T {
	var helper func([]T, int)
	permutations := [][]T{}

	helper = func(arr []T, n int) {
		if n == 1 {
			tmp := make([]T, len(arr))
			copy(tmp, arr)
			permutations = append(permutations, tmp)
		} else {
			for i := 0; i < n; i++ {
				helper(arr, n-1)
				if n%2 == 1 {
					arr[i], arr[n-1] = arr[n-1], arr[i]
				} else {
					arr[0], arr[n-1] = arr[n-1], arr[0]
				}
			}
		}
	}

	helper(slice, len(slice))
	return permutations
}

func Intersection[T comparable](slices ...[]T) []T {
	intersect := []T{}
	intersect = append(intersect, slices[0]...)

	for i := 1; i < len(slices); i++ {
		partial := []T{}

		for _, item1 := range intersect {
			for _, item2 := range slices[i] {
				if item1 == item2 {
					partial = append(partial, item1)
				}
			}
		}

		intersect = partial
	}

	return intersect
}
