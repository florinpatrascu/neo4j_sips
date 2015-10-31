defmodule Neo4j.Sips.Server.Test do
  use ExUnit.Case, async: true

  alias Neo4j.Sips.Server

  test "invalid server configuration" do
    Server.init [foo: "bar"]
    assert {:error, _} = Server.init []
    assert {:error, _} = Server.init [foo: "bar"]
    assert {:error, _} = Server.init [url: "htt://nothin'"]
  end
end
