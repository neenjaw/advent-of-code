defmodule SolutionTest do
  use ExUnit.Case

  @input_file "input.txt"

  setup do
    input = Utils.read_input(@input_file)
    {:ok, input: input}
  end

  test "Part 1 should return the expected result", %{input: input} do
    result = Solution.solve(input)

    # Example: "test" (4) + "line" (4) = 8
    expected_result = 8

    assert result == expected_result,
           "Part 1 failed: Expected #{expected_result}, got #{result}"
  end

  test "Part 2 should return the expected result", %{input: input} do
    result = Solution.solve(input)

    expected_result = "TBD"

    assert result == expected_result,
           "Part 2 failed: Expected #{expected_result}, got #{result}"
  end
end
