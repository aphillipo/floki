defmodule Floki.IdsSeeder do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def seed do
    GenServer.call(__MODULE__, :seed)
  end

  def ids do
    GenServer.call(__MODULE__, :ids)
  end

  ## GenServer API

  def handle_call(:seed, _from, state) do
    new_id = :crypto.strong_rand_bytes(8) |> Base.encode64

    {:reply, new_id, [new_id|state]}
  end

  def handle_call(:ids, _from, state) do
    {:reply, state}
  end
end
