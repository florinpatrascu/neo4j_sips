defmodule Neo4j.Sips.Utils do
  @moduledoc "Common utilities"

  # Generate a random string.
  def random_id, do: :random.uniform |> Float.to_string |> String.slice(2..10)

  @doc """
  Given a list of queries i.e. [{"cypher statament ..."}, %{parameters...}], this
  method will return a JSON that may look like this:

  {
    "statements" : [ {
      "statement" : "CREATE (n {props}) RETURN n",
      "parameters" : {
        "props" : {
          "name" : "My Node"
        }
      }
    } ]
  }
  """
  def neo4j_statements(queries, options \\ nil) when is_list(queries) do
    make_neo4j_statements(queries, [], options)
  end

  # private stuff

  defp make_neo4j_statements([], acc, options) do
    to_json(%{statements: Enum.reverse(acc)})
  end

  # some of the methods here are a customized variant from a similar project:
  # - https://github.com/raw1z/ex_neo4j

  defp make_neo4j_statements([query|tail], acc, options) when is_binary(query) do
    statement = neo4j_statement(query, %{}, options)
    make_neo4j_statements(tail, [statement|acc], options)
  end

  defp make_neo4j_statements([{query, params}|tail], acc, options) do
    statement = neo4j_statement(query, params, options)
    make_neo4j_statements(tail, [statement|acc], options)
  end

  defp neo4j_statement(query, params, options) do
    q = String.strip(query)
    if String.length(q) > 0 do
      statement = %{ statement: q}
      if Map.size(params) > 0 do
        statement = Map.merge(statement, %{parameters: params})
      end

      if options do
        statement = Map.merge(statement, options)
      end

      statement
    end
  end

  defp to_json(value, options \\ []) do
    Poison.encode!(value, options)
    |> IO.iodata_to_binary
  end

end
