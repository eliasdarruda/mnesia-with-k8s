defmodule Test.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # set abs_path for prod
    if abs_path = Application.get_env(:test, :abs_path, false) do
      # this is necessary to be called on runtime, this will set the
      # mnesia path to be dynamic based on configured volume mount
      Application.put_env(:mnesia, :dir, "#{abs_path}#{System.get_env("POD_NAME")}" |> to_charlist())
    end

    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: Test.ClusterSupervisor]]},
      Test.CustomMnesiacSupervisor,
      {Bandit, port: 9090, plug: Test.HealthCheck.Router, scheme: :http}, # for healthcheck
      Test.DummyWriter
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lplov.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
