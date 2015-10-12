defmodule Neo4j.Sips.Server.Test do
  use ExUnit.Case, async: true

  @db_url Neo4j.Sips.config(:url)

  alias Neo4j.Sips.Server

  setup_all do
    case Server.init(url: @db_url, timeout: 60) do
      {:ok, server}     -> {:ok, %{server: server}}
      {:error, message} -> Mix.raise message
    end
  end

  test "server is available to other tests", %{server: server} do
    assert server.data_url == @db_url <> "/db/data/"
  end

end
