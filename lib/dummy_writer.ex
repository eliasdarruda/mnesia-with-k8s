defmodule Test.DummyWriter do
  use GenServer

  require Logger

  def init(_) do
    Logger.info("Starting Writer")

    :mnesia.subscribe({:table, Test.ExampleStore, :simple})

    Process.send_after(self(), :increment, 5_000)

    {:ok, nil}
  end

  def handle_info(:increment, state) do
    value =
      :mnesia.dirty_read({Test.ExampleStore, "counter"})
      |> case do
        [{Test.ExampleStore, "counter", value}] -> value
        [] -> 0
      end

    Logger.info("Got value #{value}")

    :ok = :mnesia.dirty_write({Test.ExampleStore, "counter", value + 1})

    Process.send_after(self(), :increment, 5_000)

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("#{inspect(msg)}")

    {:noreply, state}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end
