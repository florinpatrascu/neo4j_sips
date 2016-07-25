defmodule Neo4j.Sips.Http do
  @moduledoc """

  module responsible with prepping the headers and delegating any requests to
  HTTPoison
  """
  use HTTPoison.Base

  @doc false
  def headers do
    ConCache.get(:neo4j_sips_cache, :http_headers)
  end

  @doc false
  @spec process_request_headers(map) :: map
  def process_request_headers(header) do
    headers ++ header
  end

end
