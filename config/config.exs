import Config

config :mnesiac,
  stores: [Test.ExampleStore],
  schema_type: :disc_copies,
  # milliseconds, default is 600_000
  table_load_timeout: 600_000

import_config "#{Mix.env()}.exs"
