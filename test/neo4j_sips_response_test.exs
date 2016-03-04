defmodule Neo4j.Sips.Response.Test do
  use ExUnit.Case, async: true

  @db_url Neo4j.Sips.config(:url)

  alias Neo4j.Sips.Response
  alias Neo4j.Sips.TestHelper
  alias Neo4j.Sips.Connection

  setup_all do
    case Connection.start_link(url: @db_url, timeout: 60) do
      {:ok, pid}      -> {:ok, %{pid: pid}}
      {:error, message} -> Mix.raise message
    end
  end

  test "loading a supported error response structure" do
    path = "./test/fixtures/error_response.json"
    sip = Poison.decode!(TestHelper.read_whole_file(path), as: Response)
    {:error, reason} = Response.to_rows(sip)
    assert length(reason) > 0 and List.first(reason)["code"] == "Neo.ClientError.Statement.InvalidSyntax"
  end

  test "loading a transaction response structure" do
    path = "./test/fixtures/tx_response.json"
    sip = Poison.decode!(TestHelper.read_whole_file(path), as: Response)
    {:ok, rows} = Response.to_rows(sip)

    assert [%{"n" => %{"name" => "My Node"}}] = rows
    assert %{"expires" => "Sun, 9 Aug 2015 14:33:42 +0000"} = sip["transaction"]
  end
end
