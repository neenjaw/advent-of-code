defmodule SolutionTest do
  use ExUnit.Case

  @input_file "input.txt"

  setup do
    input_lines = Utils.read_input_lines(@input_file)
    {:ok, input_lines: input_lines}
  end

  test "Part 1 should return the expected result", %{input_lines: input_lines} do
    result = Solution.solve(input_lines)

    # Example: "test" (4) + "line" (4) = 8
    expected_result = 8

    assert result.part1 == expected_result,
           "Part 1 failed: Expected #{expected_result}, got #{result.part1}"
  end

  test "Part 2 should return the expected result", %{input_lines: input_lines} do
    result = Solution.solve(input_lines)

    expected_result = "TBD"

    assert result.part2 == expected_result,
           "Part 2 failed: Expected #{expected_result}, got #{result.part2}"
  end
end
