defmodule Neo4j.Sips.Query do
  @moduledoc ~S"""
  Provides the Query DSL.
  """

  alias Neo4j.Sips.Transaction
  alias Neo4j.Sips.Response

  def query(conn, statement) do
    {:ok, response} = Transaction.tx_commit(conn, statement)
    case Response.to_rows(response) do
      {:ok, rows} -> {:ok, List.first(rows)}
      {:error, reason} -> {:error, List.first(reason)}
    end
  end

  def query!(conn, statement) do
    case query(conn, statement) do
      {:ok, response} -> response
      {:error, reason} ->  raise Neo4j.Sips.Error, code: reason["code"], message: reason["message"]
    end
  end

  def query(conn, statement, params) when is_map(params) do
    {:ok, response} = Transaction.tx_commit(conn, statement, params)
    case Response.to_rows(response) do
      {:ok, rows} -> {:ok, List.first(rows)}
      {:error, reason} -> {:error, List.first(reason)}
    end
  end

  def query!(conn, statement, params) when is_map(params) do
    case query!(conn, statement, params) do
      {:ok, response} -> response
      {:error, reason} ->  raise Neo4j.Sips.Error, code: reason["code"], message: reason["message"]
    end
  end
end
