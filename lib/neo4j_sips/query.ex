defmodule Neo4j.Sips.Query do
  @moduledoc ~S"""
  Provides the Query DSL.
  """

  alias Neo4j.Sips.Transaction
  alias Neo4j.Sips.Response

  def query(conn, statement) do
    {:ok, response} = Transaction.tx_commit(conn, statement)

    options = nil
    if conn.options && Map.has_key?(conn.options, :resultDataContents) do
      options = conn.options[:resultDataContents]
    end

    query_response(response, options)
  end

  def query!(conn, statement) do
    case query(conn, statement) do
      {:ok, response} -> response
      {:error, reason} ->  raise Neo4j.Sips.Error, code: reason["code"], message: reason["message"]
    end
  end

  def query(conn, statement, params) when is_map(params) do
    {:ok, response} = Transaction.tx_commit(conn, statement, params)

    options = nil
    if conn.options && Map.has_key?(conn.options, :resultDataContents) do
      options = conn.options[:resultDataContents]
    end
    query_response(response, options)
  end

  def query!(conn, statement, params) when is_map(params) do
    case query!(conn, statement, params) do
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

end
