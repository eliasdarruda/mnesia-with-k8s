defmodule Test.HealthCheck.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  alias Plug.Conn

  @content_type "application/json"

  get "/" do
    data = %{status: "up"}

    conn
    |> Conn.put_resp_content_type(@content_type)
    |> send_resp(200, Jason.encode!(data))
  end

  get "/liveness" do
    data = %{status: "up"}

    conn
    |> Conn.put_resp_content_type(@content_type)
    |> send_resp(200, Jason.encode!(data))
  end

  get "/readiness" do
    case Mnesiac.StoreManager.ensure_tables_loaded() do
      :ok ->
        data = %{status: "up"}

        conn
        |> Conn.put_resp_content_type(@content_type)
        |> send_resp(200, Jason.encode!(data))

      _ ->
        data = %{status: "down"}

        conn
        |> Conn.put_resp_content_type(@content_type)
        |> send_resp(503, Jason.encode!(data))
    end
  end

  match _ do
    send_resp(conn, 404, "Not found!")
  end
end
