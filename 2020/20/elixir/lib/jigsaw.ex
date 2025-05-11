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

    image_rows =
      file_path
      |> File.read!()
      |> Image.from_file()
      |> Image.Scaffold.scaffold_to_image_rows()

    pattern = Image.Pattern.seamonster_rows() |> Image.Pattern.compile_pattern()

    Image.Pattern.search_and_overwrite_pattern(image_rows, pattern)
  end
end
