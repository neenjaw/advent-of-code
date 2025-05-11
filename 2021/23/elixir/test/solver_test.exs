defmodule SolverTest do
  use ExUnit.Case
  doctest Solver

  test "greets the world" do
    hallway = Solver.Hallway.new()
    rooms = Solver.Rooms.initial()

    Solver.run(rooms, hallway)
  end
end
