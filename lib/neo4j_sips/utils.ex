defmodule Neo4j.Sips.Utils do
  @moduledoc "Common utilities"

  @doc """
  Generate a random string.
  """
  def random_id, do: :rand.uniform |> Float.to_string |> String.slice(2..10)

  @doc """
  Fills in the given `opts` with default options.
  """
  @spec default_config(Keyword.t) :: Keyword.t
  def default_config(config \\ Application.get_env(:neo4j_sips, Neo4j)) do
    config
    |> Keyword.put_new(:url, System.get_env("NEO4J_URL") || "http://localhost:7474")
    |> Keyword.put_new(:pool_size, 5)
    |> Keyword.put_new(:max_overflow, 2)
    |> Keyword.put_new(:timeout, 5000)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end

  @doc """
  Given a list of queries i.e. `[{"cypher statement ..."}, %{parameters...}]`, this
  method will return a JSON that may look like this:

    ````
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
    ````

  """
  def neo4j_statements(queries, options \\ nil) when is_list(queries) do
    make_neo4j_statements(queries, [], options)
  end

  @doc """
  use a collection for finding and extracting elements with a given name
  """
  def get_element(c, name) do
    List.first(Enum.map(c, &(Map.get(&1, name))))
  end

  # private stuff

  defp make_neo4j_statements([], acc, _options) when acc == [nil], do: ""

  defp make_neo4j_statements([], acc, _options) do
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
      %{statement: q}
      |> merge_params(params)
      |> merge_options(options)
    end
  end
  defp merge_params(statement, params) when map_size(params)> 0 do
    Map.merge(statement, %{parameters: params})
  end
  defp merge_params(statement, _), do: statement
  defp merge_options(statement, opts) when is_nil(opts), do: statement
  defp merge_options(statement, opts), do: Map.merge(statement, opts)

  defp to_json(value, options \\ []) do
    IO.iodata_to_binary(Poison.encode!(value, options))
  end

end
