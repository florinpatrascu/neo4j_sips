defmodule Neo4j.Sips.Transaction.Test do
  use ExUnit.Case, async: true

  alias Neo4j.Sips, as: Neo4j

  test "there is a valid commit link at the beginning of a transaction" do
    conn = Neo4j.conn
    assert String.length(conn.commit_url) == 0,
      "this is not a new connection. Its: commit_url, must be empty"

    new_conn = Neo4j.tx_begin(conn)
    assert String.length(new_conn.commit_url) != 0, "invalid commit_url"

    pattern = Regex.compile!("#{new_conn.transaction_url}/\\d+")
    assert Regex.match?(pattern, new_conn.commit_url),
      "invalid commit url: #{new_conn.commit_url}, received from server"

  end

  test "execute statements in an open transaction" do
    conn = Neo4j.tx_begin(Neo4j.conn)
    books = Neo4j.query(conn, "CREATE (b:Book {title:\"The Game Of Trolls\"}) return b")
    assert {:ok, rows} = books
    assert List.first(rows)["b"]["title"] == "The Game Of Trolls"
    assert String.length(conn.commit_url) > 0,
      "this is not an existing connection. Its commit_url, must not be empty"
    assert  {:ok, conn} = Neo4j.tx_rollback(conn)
    assert String.length(conn.commit_url) == 0
  end
end
