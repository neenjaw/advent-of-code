package mapfunc

func ContainsAllKeys(m map[string]string, keys []string) bool {
	for _, key := range keys {
		if _, ok := m[key]; !ok {
			return false
		}
	}
	return true
}
