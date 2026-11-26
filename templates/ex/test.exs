ExUnit.start()

Code.require_file("solution.exs", __DIR__)

defmodule SolutionTest do
  use ExUnit.Case, async: true

  test "part 1 with its sample" do
    input = File.read!(Path.join(__DIR__, "sample_part1.txt"))

    assert Solution.part1(input) == 8
  end

  test "part 2 with its sample" do
    input = File.read!(Path.join(__DIR__, "sample_part2.txt"))

    assert Solution.part2(input) == 3
  end
end
