# Treating Button / Constraints as System of Linear Equations

## Summary

The problem can't be solved with a gaussian elimination because it isn't guaranteed that that the matrix is square to be able to invert and do matrix multiplication.

## Using hand-written gaussian elimination

```ruby
def pick(matrix, n)
  raise "not array" unless matrix.is_a?(Array)
  raise "no rows" if matrix.length.zero?
  raise "rows aren't arrays" unless matrix.all? { it.is_a?(Array) }

  matrix_width = matrix.first.length

  pp matrix_width

  raise "unequal rows" unless matrix.all? { it.length == matrix_width }
  raise "can't slice" unless n <= matrix_width

  Enumerator.new do |y|
    (0...matrix_width).to_a.combination(n).each do |c|
      y << matrix.map { it.values_at(*c)}
    end
  end
end

def initialize_machine(machine)
  matrix = machine
    .requirements
    .values
    .map
    .with_index do |target, i|
      equation = machine.buttons.inject([]) do |equation, button|
        coefficient = button.connections.include?(i) ? 1 : 0
        equation << coefficient.to_f
      end
      equation << target.to_f
    end

  pp matrix

  rows = matrix.length
  cols = matrix[0].length

  rows.times do |i|
    # --- PARTIAL PIVOTING ---
    # Find the row with the largest value in this column (from current row downwards)
    max_row = i
    (i + 1...rows).each do |k|
      if matrix[k][i].abs > matrix[max_row][i].abs
        max_row = k
      end
    end

    # Swap the current row with the max_row
    matrix[i], matrix[max_row] = matrix[max_row], matrix[i]

    # Check if the pivot is still zero (means the system is unsolvable)
    if matrix[i][i].abs < 1e-10
      raise "System is singular or has no unique solution"
    end
    # -----------------------

    # Proceed with elimination as before
    pivot = matrix[i][i]
    (i + 1...rows).each do |j|
      factor = matrix[j][i].to_f / pivot
      (i...cols).each do |k|
        matrix[j][k] -= factor * matrix[i][k]
      end
    end
  end

  # ... (Back substitution stays exactly the same as before)
  results = Array.new(rows)
  (rows - 1).downto(0) do |i|
    sum = 0
    (i + 1...rows).each do |j|
      sum += matrix[i][j] * results[j]
    end
    results[i] = (matrix[i][cols - 1] - sum) / matrix[i][i]
  end

  results
end
```

## Using Matrices

```ruby
def pick(matrix, n)
  raise "not array" unless matrix.is_a?(Array)
  raise "no rows" if matrix.length.zero?
  raise "rows aren't arrays" unless matrix.all? { it.is_a?(Array) }

  matrix_width = matrix.first.length

  pp matrix_width

  raise "unequal rows" unless matrix.all? { it.length == matrix_width }
  raise "can't slice" unless n <= matrix_width

  Enumerator.new do |y|
    (0...matrix_width).to_a.combination(n).each do |c|
      y << matrix.map { it.values_at(*c)}
    end
  end
end

def initialize_machine(machine)
  pp machine
  coefficients = machine
    .requirements
    .values
    .map
    .with_index do |target, i|
      machine.buttons.inject([]) do |equation, button|
        coefficient = button.connections.include?(i) ? 1 : 0
        equation << coefficient
      end
    end

  constants = machine.requirements.values
  num_constants = constants.length

  pick(coefficients, num_constants).each do |picked_coefficients|
    a = Matrix[*picked_coefficients]
    b = Vector[*constants]

    begin
      solution = a.inv * b
      return solution.to_a
    rescue ExceptionForMatrix::ErrNotRegular
      return "No unique solution exists (Matrix is singular)."
    end
  end results
end
```

## Examples

### Example 1

```text
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}

x1 => number of times pressing (3)
x2 => number of times pressing (1,3)
x3 => number of times pressing (2)
x4 => number of times pressing (2,3)
x5 => number of times pressing (0,2)
x6 => number of times pressing (0,1)

counter 0, target 3
  0x1 + 0x2 + 0x3 + 0x4 + 1x5 + 1x6 = 3
counter 1, target 5
  0x1 + 1x2 + 0x3 + 0x4 + 0x5 + 1x6 = 5
counter 2, target 4
  0x1 + 0x2 + 1x3 + 1x4 + 1x5 + 0x6 = 4
counter 3, target 7
  1x1 + 1x2 + 0x3 + 1x4 + 0x5 + 0x6 = 7
```

This example is overdetermined, more variables than constants.

### Example 2

```text
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}

0, t = 7
  1x1 + 0x2 + 1x3 + 1x4 + 0x5 = 7
1, t = 5
  0x1 + 0x2 + 0x3 + 1x4 + 1x5 = 5
2, t = 12
  1x1 + 1x2 + 0x3 + 1x4 + 1x5 = 12
3, t = 7
  1x1 + 1x2 + 0x3 + 0x4 + 1x5 = 7
4, t = 2
  1x1 + 0x2 + 1x3 + 0x4 + 1x5 = 2
```

This example is determined.

### Example 3

```text
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}

0, t = 10
  1x1 + 1x2 + 1x3 + 0x4 = 10
1, t = 11
  1x1 + 0x2 + 1x3 + 1x4 = 11
2, t = 11
  1x1 + 0x2 + 1x3 + 1x4 = 11
3, t = 5
  1x1 + 1x2 + 0x3 + 0x4 = 5
4, t = 10
  1x1 + 1x2 + 1x3 + 0x4 = 10
5, t = 5
  0x1 + 0x2 + 1x3 + 0x4 = 5
```

This example is underdetermined, there are more constants than variables.
