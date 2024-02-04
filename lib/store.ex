defmodule Test.ExampleStore do
  @moduledoc """
  Provides the structure of ExampleStore records for a minimal example of Mnesiac.
  """
  use Mnesiac.Store

  require Logger

  import Record, only: [defrecord: 3]

  @doc """
  Record definition for ExampleStore example record.
  """
  defrecord(
    :example,
    __MODULE__,
    id: nil,
    count: nil
  )

  @typedoc """
  ExampleStore example record field type definitions.
  """
  @type example ::
          record(
            :example,
            id: String.t(),
            count: number()
          )

  @impl true
  def init_store do
    table_name = Keyword.get(store_options(), :record_name, __MODULE__)

    # By matching expected values if the table or store definitions is wrong it will error
    result =
      case :mnesia.create_table(table_name, store_options()) do
        {:aborted, {:already_exists, table}} -> {:aborted, {:already_exists, table}}
        {:atomic, :ok} -> {:atomic, :ok}
      end

    Logger.info("#{__MODULE__} Initialized with result #{inspect(result)}")

    result
  end

  @impl true
  def store_options do
    [
      record_name: __MODULE__, # this needs to be __MODULE__
      attributes: example() |> example() |> Keyword.keys(),
      disc_copies: [Node.self()]
    ]
  end

  @impl true
  def copy_store do
    table_name = Keyword.get(store_options(), :record_name, __MODULE__)

    result = :mnesia.add_table_copy(table_name, node(), :disc_copies)

    Logger.info("#{__MODULE__} Added table copy with result #{inspect(result)}")
  end

  @impl true
  def resolve_conflict(target_node) do
    table_name = Keyword.get(store_options(), :record_name, __MODULE__)

    Logger.warning("Resolving conflict for table #{table_name} - with #{target_node} and #{node()}")

    # assume the copy is the right version
    :mnesia.add_table_copy(table_name, node(), :disc_copies)

    :ok
  end
end
