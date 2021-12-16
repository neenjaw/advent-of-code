defmodule DayTest do
  use ExUnit.Case
  doctest Day

  def run_reduce(input) do
    input
    |> BinTree.parse()
    |> BinTree.reduce()
    |> BinTree.to_string()
  end

  def run_add(a, b) do
    a = BinTree.parse(a)
    b = BinTree.parse(b)

    a
    |> BinTree.add(b)
    |> BinTree.to_string()
  end

  describe "reduction" do
    test "[[[[[9,8],1],2],3],4]" do
      ans = run_reduce("[[[[[9,8],1],2],3],4]")
      assert ans === "[[[[0,9],2],3],4]"
    end

    test "[7,[6,[5,[4,[3,2]]]]]" do
      ans = run_reduce("[7,[6,[5,[4,[3,2]]]]]")
      assert ans === "[7,[6,[5,[7,0]]]]"
    end

    test "[[6,[5,[4,[3,2]]]],1]" do
      ans = run_reduce("[[6,[5,[4,[3,2]]]],1]")
      assert ans === "[[6,[5,[7,0]]],3]"
    end

    test "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]" do
      ans = run_reduce("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
      assert ans === "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"
    end

    test "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]" do
      ans = run_reduce("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
      assert ans === "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"
    end
  end

  describe "single add" do
    test "[[[[4,3],4],4],[7,[[8,4],9]]] + [1,1]" do
      ans = run_add("[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]")
      assert ans === "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
    end
  end

  describe "chain add" do
    test "ex1" do
      final =
        Day.add_ex1()
        |> String.split("\n", trim: true)
        |> Enum.map(&BinTree.parse/1)
        |> Enum.reduce(fn t, sum ->
          BinTree.add(sum, t)
        end)
        |> BinTree.to_string()

      assert final == "[[[[1,1],[2,2]],[3,3]],[4,4]]"
    end

    test "ex2" do
      final =
        Day.add_ex2()
        |> String.split("\n", trim: true)
        |> Enum.map(&BinTree.parse/1)
        |> Enum.reduce(fn t, sum ->
          BinTree.add(sum, t)
        end)
        |> BinTree.to_string()

      assert final == "[[[[3,0],[5,3]],[4,4]],[5,5]]"
    end

    test "ex3" do
      final =
        Day.add_ex3()
        |> String.split("\n", trim: true)
        |> Enum.map(&BinTree.parse/1)
        |> Enum.reduce(fn t, sum ->
          BinTree.add(sum, t)
        end)
        |> BinTree.to_string()

      assert final == "[[[[5,0],[7,4]],[5,5]],[6,6]]"
    end

    test "ex4" do
      final =
        Day.add_ex4()
        |> String.split("\n", trim: true)
        |> Enum.map(&BinTree.parse/1)
        |> Enum.reduce(fn t, sum ->
          BinTree.add(sum, t)
        end)
        |> BinTree.to_string()

      assert final == "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
    end

    test "input" do
      final =
        Day.input()
        |> String.split("\n", trim: true)
        |> Enum.map(&BinTree.parse/1)
        |> Enum.reduce(fn t, sum ->
          BinTree.add(sum, t)
        end)
        |> BinTree.sum_magnitude()

      assert final == 3359
    end

    test "input2" do
      trees =
        Day.input()
        |> String.split("\n", trim: true)
        |> Enum.map(&BinTree.parse/1)
        |> Enum.with_index()

      values =
        for {a, i} <- trees,
            {b, j} <- trees,
            i !== j do
          BinTree.add(a, b)
          |> BinTree.sum_magnitude()
        end

      assert Enum.max(values) == 3359
    end
  end
end
