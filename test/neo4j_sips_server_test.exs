defmodule Neo4j.Sips.Server.Test do
  use ExUnit.Case, async: true

  alias Neo4j.Sips.Server
  @db_url Neo4j.Sips.Utils.default_config()[:url]

  test "server initialization" do
    case Server.init(url: @db_url, timeout: 60) do
      {:ok, pid}        -> {:ok, %{pid: pid}}
      {:error, message} -> Mix.raise message
    end
  end

  test "invalid server configuration" do
    assert {:error, _} = Server.init []
    assert {:error, _} = Server.init [foo: "bar"]
    assert {:error, _} = Server.init [url: "htt://nothin'"]
  end

  test "headers without authentication" do
    Server.init(url: @db_url)
    assert Keyword.get(Server.headers, :Authorization) == nil
  end

  test "headers containing the authentication token" do
    token = "bmVvNGo6dGVzdA="
    Server.init(url: @db_url, token_auth: token)
    assert Keyword.get(Server.headers, :Authorization) == "Basic #{token}"
  end

  test "headers containing a proper token for basic_auth" do
    Server.init(url: @db_url, basic_auth: [username: "neo4j", password: "neo4j"])
    assert Keyword.get(Server.headers, :Authorization) == "Basic bmVvNGo6bmVvNGo="
  end

end
