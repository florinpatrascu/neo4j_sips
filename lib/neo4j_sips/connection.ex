defmodule Neo4j.Sips.Connection do
  @moduledoc """
  The Connection module.

  This module defines a `Neo4j.Sips.Connection` structure containing important
  server details. For efficiency, and because we need an initial dialog with the
  server for finding the REST API endpoints, the server details are cached and reused.

  """

  defstruct [:server, :transaction_url, :server_version, :commit_url, :options]

  use GenServer

  import Kernel, except: [send: 2]

  alias Neo4j.Sips.Server
  alias Neo4j.Sips.Http, as: HTTP

  require Logger

  @doc """
  Starts the connection process. Please check the config files for the connection
  options
  """
  @spec start_link(Keyword.t) :: GenServer.on_start
  def start_link(params) do
    # IO.puts("#{inspect(__MODULE__)}:start_link " <> inspect(params))
    GenServer.start_link(__MODULE__, params, [])
  end

  ## Server callbacks
  @doc false
  def init(opts) do
    case Server.init opts do
      {:ok, server} ->
        connection = %Neo4j.Sips.Connection{
                    server: server,
                    transaction_url: server.data.transaction,
                    server_version: server.data.neo4j_version,
                    commit_url: "",
                    options: nil
                  }

        ConCache.put(:neo4j_sips_cache, :conn, connection)
        {:ok, conn}
      {:error, message} -> {:error, message}
    end
  end

  @doc false
  def handle_call(data, _from, state) do
    result = case data do
      {:post, url, body} -> decode_as_response(HTTP.post!(url, body).body)
      {:delete, url, _}  -> decode_as_response(HTTP.delete!(url).body)
      {:get, url, _} ->
          case HTTP.get(url) do
            {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: 200}} -> Poison.decode!(body)
            {:error, %HTTPoison.Error{id: id, reason: reason}} -> {:error, reason}
            {:ok, _} -> []
          end
    end
    # :random.seed(:os.timestamp)
    # timeout = state[:timeout] || 5000
    {:reply, result, state}
  end

  @doc false
  def send(method, connection, body \\ "") do
    pool_server(method, connection, body)
  end

  defp pool_server(method, connection, body) do
    :poolboy.transaction(
      Neo4j.Sips.pool_name, &(:gen_server.call(&1, {method, connection, body})),
      Neo4j.Sips.config(:timeout)
    )
  end

  @doc false
  def terminate(_reason, _state) do
    :ok
  end


  @doc """
  returns a Connection containing the server details. You can
  specify some optional parameters i.e. graph_result.

  graph_result is nil, by default, and can have the following values:

      graph_result: ["row"]
      graph_result: ["graph"]
  or both:

      graph_result: [ "row", "graph" ]

  """
  def conn(options) do
    Map.put(ConCache.get(:neo4j_sips_cache, :conn), :options, options)
  end

  @doc """
  returns a Neo4j.Sips.Connection
  """
  def conn() do
    ConCache.get(:neo4j_sips_cache, :conn)
  end

  @doc """
  returns the version of the Neo4j server you're connected to
  """
  def server_version() do
    conn.server_version
  end

  defp decode_as_response(resp) do
    case Poison.decode(resp, as: Neo4j.Sips.Response) do
      {:ok, sip} -> {:ok, sip}
      error      -> {:error, error}
    end
  end

end
