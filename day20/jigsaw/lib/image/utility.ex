defmodule Image.Utility do
  @rotations [0, 90, 180, 270]
  @vflip [false, true]
  @hflip [false, true]

  def generate_combinations() do
    for rotation <- @rotations, vflip <- @vflip, hflip <- @hflip, do: {rotation, vflip, hflip}
  end
end
