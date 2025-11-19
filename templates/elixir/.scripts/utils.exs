defmodule Utils do
  @moduledoc """
  Common utilities for Advent of Code solutions.
  """

  @doc """
  Reads the input file and returns a list of lines (non-empty lines only).

  ## Examples

      iex> Utils.read_input_lines("input.txt")
      ["line1", "line2", "line3"]
  """
  def read_input_lines(file_path) do
    file_path
    |> File.read!()
    |> String.split(~r/\r?\n/)
    |> Enum.reject(&(&1 == ""))
  end

  @doc """
  Reads the input file and returns the entire content as a string.
  """
  def read_input(file_path) do
    File.read!(file_path)
  end

  @doc """
  Reads the input file and returns lines including empty ones.
  """
  def read_input_lines_with_empty(file_path) do
    file_path
    |> File.read!()
    |> String.split(~r/\r?\n/)
  end
end
