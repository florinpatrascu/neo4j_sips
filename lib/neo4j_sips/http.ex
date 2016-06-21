defmodule Neo4j.Sips.Http do
  @moduledoc """

  module responsible with prepping the headers and delegating any requests to
  HTTPoison
  """
  use HTTPoison.Base

  token_auth =
    if Neo4j.Sips.config[:token_auth] != nil do
      token_auth = Neo4j.Sips.config[:token_auth]
      def auth_token, do: unquote(Macro.escape(token_auth))
      token_auth
    else
      def auth_token, do: nil
      if basic_auth = Neo4j.Sips.config[:basic_auth] do
        username = basic_auth[:username]
        password = basic_auth[:password]
        Base.encode64("#{username}:#{password}")
      else
        nil
      end
    end

  @headers [
    "Accept": "application/json; charset=UTF-8",
    "Content-Type": "application/json; charset=UTF-8",
    "User-Agent": "Neo4j.Sips client",
    "X-Stream": "true",
    "Authorization": "Basic #{token_auth}"
  ]

  @doc false
  @spec process_request_headers(map) :: map
  def process_request_headers(header) do
    @headers ++ header
  end

  def headers do
    @headers
  end
end
