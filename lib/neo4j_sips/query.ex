defmodule Neo4j.Sips.Query do
  @moduledoc ~S"""
  Provides the Query DSL.
  """
  alias Neo4j.Sips.Connection
  alias Neo4j.Sips.Response
  alias Neo4j.Sips.Utils

  @commit "/commit"

  def query(conn, statement) do
    {:ok, response} = query_commit(conn, statement)
    do_query(response, conn)
  end
  def query(conn, statement, params) when is_map(params) do
    {:ok, response} = query_commit(conn, statement, params)
    do_query(response, conn)
  end

  defp do_query(response, conn) do
    options =
      if conn.options && Map.has_key?(conn.options, :resultDataContents) do
        conn.options[:resultDataContents]
      end || nil

    query_response(response, options)
  end
    

  def query!(conn, statement),  do: query(conn,statement) |> do_query!
  def query!(conn, statement, params) when is_map(params) do
    query(conn, statement, params) |> do_query!
  end
  defp do_query!(result) do
    case result do
      {:ok, response} -> response
      {:error, reason} ->  raise Neo4j.Sips.Error, code: reason["code"], message: reason["message"]
    end
  end

  defp query_response(response, options) do
    if options do
      Response.to_options(response, options)
    else
      case Response.to_rows(response) do
        {:error, reason} -> {:error, reason}
        {:ok, rows} -> {:ok, rows}
      end
    end
  end


  @doc """
    This is different than Transaction's same function, since we only commit if there are no open transactions
  """
  def commit_url(conn) do
    if( String.length(conn.commit_url) > 0, do: conn.commit_url, else: conn.transaction_url <> @commit)
  end

  defp query_commit(conn, statements) when is_list(statements) do
    Connection.send(:post, commit_url(conn), Utils.neo4j_statements(statements, conn.options))
  end

  defp query_commit(conn, statement, params \\ %{}) do
    Connection.send(:post, commit_url(conn), Utils.neo4j_statements([{statement, params}], conn.options))
  end

end
