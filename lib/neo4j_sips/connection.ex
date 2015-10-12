defmodule Neo4j.Sips.Connection do
  defstruct [:server, :transaction_url, :server_version, :commit_url]

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
    GenServer.start_link(__MODULE__, params, [])
  end

  ## Server callbacks
  def init(opts) do
    case Server.init opts do
      {:ok, server} ->
        conn = %Neo4j.Sips.Connection{server: server,
                               transaction_url: server.data.transaction,
                               server_version: server.data.neo4j_version,
                               commit_url: ""}
        ConCache.put(:neo4j_sips_cache, :conn, conn)
        {:ok, conn}
      {:error, message} -> {:error, message}
    end
  end

  def handle_call(data, _from, state) do
    response = case data do
      {:post, url, body} ->
        HTTP.post!(url, body)
      {:delete, url, _} ->
        HTTP.delete!(url)
    end

    result = case Poison.decode(response.body, as: Neo4j.Sips.Response) do
      {:ok, sip} -> {:ok, sip}
      error      -> {:error, error}
    end

    # :random.seed(:os.timestamp)
    # timeout = state[:timeout] || 5000
    {:reply, result, state}
  end

  def send(method, conn, body \\ "") do
    pool_server(method, conn, body)
  end

  defp pool_server(method, conn, body) do
    :poolboy.transaction(
      Neo4j.Sips.pool_name, &(:gen_server.call(&1, {method, conn, body})),
      Neo4j.Sips.config(:timeout)
    )
  end

  def terminate(_reason, _state) do
    :ok
  end


  @doc """

  return a Connection containing the server details
  """
  @spec conn :: Neo4j.Sips.Connection
  def conn do
    ConCache.get(:neo4j_sips_cache, :conn)
  end

  def server_version() do
   conn.server_version
  end

end
