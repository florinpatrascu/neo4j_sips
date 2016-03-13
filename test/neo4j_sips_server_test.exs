defmodule Neo4j.Sips.Server.Test do
  use ExUnit.Case, async: true

  alias Neo4j.Sips.Server
  @db_url Neo4j.Sips.config(:url)


  setup_all do
    case Server.init(url: @db_url, timeout: 60) do
      {:ok, pid}      -> {:ok, %{pid: pid}}
      {:error, message} -> Mix.raise message
    end
  end

  test "invalid server configuration" do
    Server.init [foo: "bar"]
    assert {:error, _} = Server.init []
    assert {:error, _} = Server.init [foo: "bar"]
    assert {:error, _} = Server.init [url: "htt://nothin'"]
  end
end
