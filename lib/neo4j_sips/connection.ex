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

  alias Neo4j.Sips.Http, as: HTTP

  require Logger

  @post "POST - "
  @delete "DELETE - "
  @get "GET - "

  @doc """
  Starts the connection process. Please check the config files for the connection
  options
  """
  def start_link(server_endpoint) do
    GenServer.start_link(__MODULE__, server_endpoint, [])
  end

  @doc false
  def handle_call(data, _from, state) do
    result = case data do
      {:post, url, body} ->
        log(@post <> "#{url} - #{body}")
        decode_as_response(HTTP.post!(url, body).body)

      {:delete, url, _}  ->
        log(@delete <> "#{url}")
        decode_as_response(HTTP.delete!(url).body)

      {:get, url, _} ->
        log(@get <> "#{url}")
        case HTTP.get(url) do
          {:ok, %HTTPoison.Response{body: body, headers: _headers, status_code: 200}} -> Poison.decode!(body)
          {:error, %HTTPoison.Error{id: _id, reason: reason}} -> {:error, reason}
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

  @doc """
  Logs the given message in debug mode.

  The logger call will be removed at compile time if `compile_time_purge_level`
  is set to higher than :debug
  """
  def log(message) when is_binary(message) do
    Logger.debug(message)
  end

  defp decode_as_response(resp) do
    case Poison.decode(resp, as: Neo4j.Sips.Response) do
      {:ok, sip} -> {:ok, sip}
      error      -> {:error, error}
    end
  end

end
