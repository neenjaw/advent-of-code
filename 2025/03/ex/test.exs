defmodule SolutionTest do
  use ExUnit.Case

  @input_file "input.txt"

  def sample1 do
    """
    987654321111111
    811111111111119
    234234234234278
    818181911112111
    """
  end

  setup do
    input_lines = Utils.read_input(@input_file)
    {:ok, input_lines: input_lines}
  end

  test "Part 1 with Sample" do
    result = Solution.part1(sample1())

    expected_result = 357

    assert result == expected_result
  end

  test "Part 1 should return the expected result", %{input_lines: input_lines} do
    result = Solution.part1(input_lines)

    expected_result = 17316

    assert result == expected_result,
           "Part 1 failed: Expected #{expected_result}, got #{result}"
  end

  test "Part 2 with Sample" do
    result = Solution.part2(sample1())

    expected_result = 3_121_910_778_619

    assert result == expected_result
  end

  # @tag :skip
  test "Part 2 should return the expected result", %{input_lines: input_lines} do
    result = Solution.part2(input_lines)

    expected_result = 171_741_365_473_332

    assert result == expected_result,
           "Part 2 failed: Expected #{expected_result}, got #{result}"
  end
end
