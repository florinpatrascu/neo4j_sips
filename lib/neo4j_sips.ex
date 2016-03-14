defmodule Neo4j.Sips do
  @moduledoc """
  Elixir driver for Neo4j

  A module that provides a simple Interface to communicate with a Neo4j server via http,
  using [Neo4j's own REST API](http://neo4j.com/docs/stable/rest-api.html).

  All functions take a pool to run the query on.
  """

  alias Neo4j.Sips.Transaction
  alias Neo4j.Sips.Connection
  alias Neo4j.Sips.Server
  alias Neo4j.Sips.Query

  @config Application.get_env(:neo4j_sips, Neo4j)
  @pool_name :neo4j_sips_pool

  if !@config, do: raise "Neo4j.Sips is not configured"
  if !Dict.get(@config, :url), do: raise "Neo4j.Sips requires the :url of the database"

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    ConCache.start_link([], name: :neo4j_sips_cache)

    poolboy_config = [
      name: {:local, @pool_name},
      worker_module: Neo4j.Sips.Connection,
      size: config(:pool_size, 1),
      max_overflow: config(:max_overflow, 0)
    ]

    conn = case Server.init(config) do
      {:ok, server} ->
        connection = %Neo4j.Sips.Connection{
                    server: server,
                    transaction_url: server.data.transaction,
                    server_version: server.data.neo4j_version,
                    commit_url: "",
                    options: nil
                  }

        {:ok, connection}
      {:error, message} -> {:error, message}
    end

    children = [
      :poolboy.child_spec(@pool_name, poolboy_config, conn)
    ]

    opts = [strategy: :one_for_one, name: Neo4j.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ## Connection

  @doc """
  returns a Connection containing the server details. You can
  specify some optional parameters i.e. graph_result.

  graph_result is nil, by default, and can have the following values:

      graph_result: ["row"]
      graph_result: ["graph"]
  or both:

      graph_result: [ "row", "graph" ]

  """
  defdelegate conn(options), to: Connection

  # until defdelegate allows optional args?!
  @doc """
  returns a Neo4j.Sips.Connection
  """
  defdelegate conn(), to: Connection

  @doc """

  returns the server version
  """
  @spec server_version() :: String.t
  defdelegate server_version(), to: Connection

  ## Query
  ########################

  @doc """
  sends the query (and its parameters) to the server and returns `{:ok, Neo4j.Sips.Response}` or
  `{:error, error}` otherwise
  """
  @spec query(Neo4j.Sips.Connection, String.t) :: {:ok, Neo4j.Sips.Response} | {:error, Neo4j.Sips.Error}
  defdelegate query(conn, statement), to: Query

  @doc """
  The same as query/2 but raises a Neo4j.Sips.Error if it fails.
  Returns the server response otherwise.
  """
  @spec query!(Neo4j.Sips.Connection, String.t) :: Neo4j.Sips.Response | Neo4j.Sips.Error
  defdelegate query!(conn, statement), to: Query

  @doc """
  send a query and an associated map of parameters. Returns the server response or an error
  """
  @spec query(Neo4j.Sips.Connection, String.t, Map.t) :: {:ok, Neo4j.Sips.Response} | {:error, Neo4j.Sips.Error}
  defdelegate query(conn, statement, params), to: Query

  @doc """
  The same as query/3 but raises a Neo4j.Sips.Error if it fails.
  """
  @spec query!(Neo4j.Sips.Connection, String.t, Map.t) :: Neo4j.Sips.Response | Neo4j.Sips.Error
  defdelegate query!(conn, statement, params), to: Query


  ## Transaction
  ########################

  @doc """
  begin a new transaction.
  """
  @spec tx_begin(Neo4j.Sips.Connection) :: Neo4j.Sips.Connection
  defdelegate tx_begin(conn), to: Transaction

  @doc """
  execute a Cypher statement in a new or an existing transaction
  begin a new transaction. If there is no need to keep a
  transaction open across multiple HTTP requests, you can begin a transaction,
  execute statements, and commit with just a single HTTP request.
  """
  @spec tx_commit(Neo4j.Sips.Connection, String.t) :: Neo4j.Sips.Response
  defdelegate tx_commit(conn, statements), to: Transaction

  @doc """
  given you have an open transaction, you can use this to send a commit request
  """
  @spec tx_commit(Neo4j.Sips.Connection) :: Neo4j.Sips.Response
  defdelegate tx_commit(conn), to: Transaction

  @doc """
  execute a Cypher statement with a map containing associated parameters
  """
  @spec tx_commit(Neo4j.Sips.Connection, String.t, Map.t) :: Neo4j.Sips.Response
  defdelegate tx_commit(conn, statement, params), to: Transaction

  @spec tx_commit!(Neo4j.Sips.Connection, String.t) :: Neo4j.Sips.Response
  defdelegate tx_commit!(conn, statements), to: Transaction

  @spec tx_commit!(Neo4j.Sips.Connection, String.t, Map.t) :: Neo4j.Sips.Response
  defdelegate tx_commit!(conn, statement, params), to: Transaction

  @doc """
  given that you have an open transaction, you can send a rollback request.
  The server will rollback the transaction. Any further statements trying to run
  in this transaction will fail immediately.
  """
  @spec tx_rollback(Neo4j.Sips.Connection) :: Neo4j.Sips.Connection
  defdelegate tx_rollback(conn), to: Transaction

  @doc """
  list all property keys ever used in the database. This also includes any property
  keys you have used, but deleted. There is currently no way to tell which ones
  are in use and which ones are not, short of walking the entire set of properties
  in the database.
  """
  @spec property_keys() :: List.t | []
  def property_keys do
    property_keys_url = Neo4j.Sips.conn.server.data_url <> "propertykeys"
    Connection.send(:get, property_keys_url)
  end

  @doc """
   returns an environment specific Neo4j.Sips configuration.

   Example of valid configurations (i.e. defined in config/dev.exs):

      # Neo4j server not requiring authentication
      config :neo4j_sips, Neo4j,
        url: "http://localhost:7474"

      # Neo4j server with username and password authentication
      config :neo4j_sips, Neo4j,
        url: "http://localhost:7474",
        pool_size: 5,
        max_overflow: 2,
        timeout: 30,
        basic_auth: [username: "neo4j", password: "neo4j"]

      # or using a token
      config :neo4j_sips, Neo4j,
        url: "http://localhost:7474",
        pool_size: 10,
        max_overflow: 5,
        timeout: :infinity,
        token_auth: "bmVvNGo6dGVzdA=="

  """
  def config, do: Application.get_env(:neo4j_sips, Neo4j)

  @doc false
  def config(key), do: Keyword.get(config, key)

  @doc false
  def config(key, default), do: Keyword.get(config, key, default)

  @doc false
  def pool_name, do: @pool_name

end
