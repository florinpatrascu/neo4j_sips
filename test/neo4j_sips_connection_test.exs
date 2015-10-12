defmodule Neo4j.Sips.Connection.Test do
  use ExUnit.Case, async: true

  alias Neo4j.Sips, as: Neo4j

  test "there the server version availability" do
    assert Neo4j.server_version =~ ~r{^\d+\.\d+\.\d+$}
  end
end
