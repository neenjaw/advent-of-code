package mymath

type number interface {
	int | int8 | int16 | int32 | int64 | float32 | float64
}

// Abs a generic function to get the absolute value of number types
func Abs[T number](value T) T {
	if value < 0 {
		return -value
	}
	return value
}

func Min[T number](a, b T) T {
	if a < b {
		return a
	}
	return b
}

func Max[T number](a, b T) T {
	if a > b {
		return a
	}
	return b
}
