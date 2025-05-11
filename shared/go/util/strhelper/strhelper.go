package strhelper

func StringDiff(a, b string) string {
	mb := make(map[rune]bool, len(b))
	for _, x := range b {
		mb[x] = true
	}
	var diff string
	for _, x := range a {
		if _, found := mb[x]; !found {
			diff = diff + string(x)
		}
	}
	return diff
}

func ChainDiff(enc string, steps []string, check []int) bool {
	d := enc
	for i, step := range steps {
		d1 := StringDiff(d, step)
		if len(d1) != check[i] {
			return false
		}
		d = d1
	}

	return true
}

func RuneFrequency(s string) (freq map[rune]int) {
	freq = make(map[rune]int)

	for _, r := range s {
		freq[r]++
	}

	return
}
