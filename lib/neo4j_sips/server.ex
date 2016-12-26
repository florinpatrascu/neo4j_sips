defmodule Neo4j.Sips.Server do
  @moduledoc ~S"""
  Provide access to a structure containing all the HTTP endpoints
  exposed by a remote (or local) Neo4j server instance

  Example extracted from a standard Neo4j server; Community Edition

      {
        "extensions" : { },
        "node" : "http://localhost:7474/db/data/node",
        "node_index" : "http://localhost:7474/db/data/index/node",
        "relationship_index" : "http://localhost:7474/db/data/index/relationship",
        "extensions_info" : "http://localhost:7474/db/data/ext",
        "relationship_types" : "http://localhost:7474/db/data/relationship/types",
        "batch" : "http://localhost:7474/db/data/batch",
        "cypher" : "http://localhost:7474/db/data/cypher",
        "indexes" : "http://localhost:7474/db/data/schema/index",
        "constraints" : "http://localhost:7474/db/data/schema/constraint",
        "transaction" : "http://localhost:7474/db/data/transaction",
        "node_labels" : "http://localhost:7474/db/data/labels",
        "neo4j_version" : "2.2.3"
      }
  """

  defstruct [:server_url, :management_url, :data_url, :data, :timeout, :bolt]

  alias Neo4j.Sips.Http, as: HTTP

  require Logger

  defmodule ServerData do
    @moduledoc false
    defstruct [
      :batch,
      :constraints,
      :cypher,
      :extensions,
      :extensions_info,
      :indexes,
      :neo4j_version,
      :node,
      :node_index,
      :node_labels,
      :relationship_index,
      :relationship_types,
      :transaction
    ]
  end

  @headers [
    "Accept": "application/json; charset=UTF-8",
    "Content-Type": "application/json; charset=UTF-8",
    "User-Agent": "Neo4j.Sips client",
    "X-Stream": "true"
  ]

  @doc """
  collect the server REST endpoints from the remote host
  """
  def init(opts \\ []) do
    {url, opts} = Keyword.pop(opts, :url, "")
    {timeout, _} = Keyword.pop(opts, :timeout, 5000)

    ConCache.put(:neo4j_sips_cache, :http_headers, @headers)

    {check_status, uri} = check_uri(url);

    token_auth = cond do
      opts[:token_auth] -> Macro.escape(opts[:token_auth])
      basic_auth = opts[:basic_auth] ->
        username = basic_auth[:username]
        password = basic_auth[:password]
        Base.encode64("#{username}:#{password}")
      uri.userinfo -> Base.encode64(uri.userinfo)
      true -> nil
    end

    if token_auth != nil do
      ConCache.put(:neo4j_sips_cache, :http_headers,
        @headers ++ ["Authorization": "Basic #{token_auth}"])
    end

    case check_status do
      :ok ->
        # "ping" the server, and check if we can connect
        case HTTP.get("#{url}/db/data/") do
          {:ok, %HTTPoison.Response{body: _body, headers: _headers, status_code: 400,}} ->
            {:error, "Cannot connect to the server at url: #{url}. Reason: Invalid Authorization"}

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, "Cannot connect to the server at url: #{url}. Reason: #{reason}"}

          {:ok, response_db_data} ->
            response_db_root = HTTP.get!("#{url}")
            %{data: data, management: management} = Poison.Parser.parse!(response_db_root.body, keys: :atoms!)
            server_data = Poison.decode!(response_db_data.body, as: ServerData, keys: :atoms) # returned by: /db/data/
            %{node_labels: _node_labels, transaction: _transaction, neo4j_version: _neo4j_version}
               = Poison.Parser.parse!(response_db_data.body, keys: :atoms!)
            {:ok, %Neo4j.Sips.Server{
                server_url: url, management_url: management, data_url: data,
                data: server_data, timeout: timeout}}
        end

      :error -> {:error, "invalid server url: #{url}"}
    end
  end

  def headers do
    ConCache.get(:neo4j_sips_cache, :http_headers)
  end

  defp check_uri(str) do
    uri = URI.parse(str)
    case uri do
      %URI{scheme: nil} -> {:error, uri}
      %URI{host: nil} -> {:error, uri}
      %URI{port: nil} -> {:error, uri}
      uri -> {:ok, uri}
    end
  end
end
