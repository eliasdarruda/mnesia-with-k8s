defmodule Test.CustomMnesiacSupervisor do
  @moduledoc false
  require Logger
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: Test.MnesiacSupervisor)
  end

  @impl true
  def init(_) do
    _ = Logger.info("[mnesiac:#{node()}] mnesiac starting, with #{inspect(Node.list())}")

    Mnesiac.init_mnesia(Node.list())
    |> case do
      :ok ->
        :ok

      {:error, {:failed_to_connect_node, node}} ->
        Logger.warning("Failed to connect node: #{node}")
    end

    _ = Logger.info("[mnesiac:#{node()}] mnesiac started")

    Supervisor.init([], strategy: :one_for_one, name: Test.MnesiacSupervisor)
  end
end
