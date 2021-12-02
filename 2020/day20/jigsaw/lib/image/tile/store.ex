defmodule Image.Tile.Store do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, write_concurrency: true]
    )

    {:ok, nil}
  end

  def put(%Image.Tile{number: n, orientation: o, vflip: vf, hflip: hf} = tile) do
    :ets.insert(__MODULE__, {{n, o, vf, hf}, tile})
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, tile}] -> {:ok, tile}
      _ -> {:error, "not found"}
    end
  end

  def info() do
    :ets.info(__MODULE__)
  end

  def size() do
    info()[:size]
  end

  def drop() do
    :ets.delete_all_objects(__MODULE__)
  end
end
