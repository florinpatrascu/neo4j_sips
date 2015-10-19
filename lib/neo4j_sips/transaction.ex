defmodule Neo4j.Sips.Transaction do
  @moduledoc """
  This module is the main implementation for running Cypher commands using
  transactions. It is using the transactional HTTP endpoint for Cypher and has
  the ability to let you use the same transaction across multiple HTTP requests.

  Every Cypher operation is executed in a transaction.

  Example:

      test "execute statements in an open transaction" do
        conn = Neo4j.tx_begin(Neo4j.conn)
        books = Neo4j.query(conn, "CREATE (b:Book {title:\"The Game Of Trolls\"}) return b")
        assert {:ok, rows} = books
        assert List.first(rows)["b"]["title"] == "The Game Of Trolls"
        assert  {:ok, conn} = Neo4j.tx_rollback(conn)
        assert String.length(conn.commit_url) == 0
      end

  To do:
  - let the user override the default TX timeout; the default timeout is 60 seconds.
  - improve the errors handling
  - Reset transaction timeout of an open transaction
  - add support for returning results in graph format
  """

  alias Neo4j.Sips.Connection
  alias Neo4j.Sips.Utils

  require Logger

  # URL suffix used for composing Neo4j transactional endpoints
  @commit "/commit"

  @doc """
  begin a new transaction. If there is no need to keep a
  transaction open across multiple HTTP requests, you can begin a transaction,
  execute statements, and commit with just a single HTTP request.
  """
  @spec tx_begin(Neo4j.Sips.Connection) :: Neo4j.Sips.Connection
  def tx_begin(conn) do
    case Connection.send(:post, conn.transaction_url) do
      {:ok, response} ->
        Map.put(conn, :commit_url, String.replace(response.commit, ~r{/commit}, ""))
      {:error, reason} -> {:error, List.first(reason)}
    end
  end

  @spec tx_rollback(Neo4j.Sips.Connection) :: Neo4j.Sips.Connection
  def tx_rollback(conn) do
    case Connection.send(:delete, conn.commit_url) do
      {:ok, _response} -> {:ok, Map.put(conn, :commit_url, "")}
      {:error, reason} ->
        case reason do
          {:error, :invalid} -> {:error, "invalid url: #{conn.commit_url}"}
          _ -> {:error, List.first(reason)}
        end
    end
  end

  @doc """
  commit an open transaction
  """
  @spec tx_commit(Neo4j.Sips.Connection) :: Neo4j.Sips.Response
  def tx_commit(conn) do
    tx_commit(conn, "")
  end

  @doc """
  send a list of cypher commands to the server. Each command will have this form:
  {query, params}, where the query is a valid Cypher command and the params are a
  map of optional parameters.
  """
  @spec tx_commit(Neo4j.Sips.Connection, String.t) :: Neo4j.Sips.Response
  def tx_commit(conn, statements) when is_list(statements) do
    commit_url = conn.transaction_url <> @commit
    if String.length(conn.commit_url) > 0 do
      commit_url = conn.commit_url
    end
    Connection.send(:post, commit_url, Utils.neo4j_statements(statements, conn.options))
  end

  @doc """
  send a single cypher command to the server, and an optional map of parameters
  """
  @spec tx_commit(Neo4j.Sips.Connection, String.t, Map.t) :: Neo4j.Sips.Response
  def tx_commit(conn, statement, params \\ %{}) do
    commit_url = conn.transaction_url <> @commit
    if String.length(conn.commit_url) > 0 do
      commit_url = conn.commit_url
    end
    Connection.send(:post, commit_url, Utils.neo4j_statements([{statement, params}], conn.options))
  end

  @doc """
  same as #tx_commit but maybe raise an error
  """
  @spec tx_commit!(Neo4j.Sips.Connection, String.t, Map.t) :: Neo4j.Sips.Response
  def tx_commit!(conn, query, params \\ %{}) do
    case tx_commit(conn, query, params) do
      {:error, reason} -> raise Neo4j.Sips.Error, code: reason["code"],
        message: reason["message"]
      {:ok, response} -> response
    end
  end
end
