defmodule Jigsaw do
  def run_example() do
    run("../example.txt")
  end

  def run_input() do
    run("../input.txt")
  end

  def run(file_path) do
    Image.Tile.Store.start_link()
    Image.Tile.Store.drop()

    File.read!(file_path)
    |> Image.from_file()
  end
end
