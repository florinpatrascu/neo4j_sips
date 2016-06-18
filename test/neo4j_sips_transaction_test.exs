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

  ###
  ### NOTE:
  ###
  ### The labels used in these examples MUST be unique across all tests!
  ### These tests depend on being able to expect that a node either exists
  ### or does not, and asynchronous testing with the same names will cause
  ### random cases where the underlying state changes.
  ###

  test "rollback statements in an open transaction" do
    try do
      # In case there's already a copy in our DB, count them...
      {:ok, result} = Neo4j.query(Neo4j.conn, "MATCH (x:XactRollback) RETURN count(x)")
      original_count = hd(result)["count(x)"]

      conn = Neo4j.tx_begin(Neo4j.conn)
      books = Neo4j.query(conn, "CREATE (x:XactRollback {title:\"The Game Of Trolls\"}) return x")
      assert {:ok, rows} = books
      assert List.first(rows)["x"]["title"] == "The Game Of Trolls"
      assert String.length(conn.commit_url) > 0,
        "this is not an existing connection. Its commit_url, must not be empty"

      # Original connection (outside the transaction) should not see this node.
      {:ok, result} = Neo4j.query(Neo4j.conn, "MATCH (x:XactRollback) RETURN count(x)")
      assert hd(result)["count(x)"] == original_count,
          "Main connection should not be able to see transactional change"

      assert  {:ok, conn} = Neo4j.tx_rollback(conn)
      assert String.length(conn.commit_url) == 0

      # Original connection should still not see this node committed.
      {:ok, result} = Neo4j.query(Neo4j.conn, "MATCH (x:XactRollback) RETURN count(x)")
      assert hd(result)["count(x)"] == original_count
    after
      # Delete all XactRollback nodes in case the tx_rollback() didn't work!
      Neo4j.query(Neo4j.conn, "MATCH (x:XactRollback) DETACH DELETE x")
    end
  end

  test "commit statements in an open transaction" do
    try do
      conn = Neo4j.tx_begin(Neo4j.conn)
      books = Neo4j.query(conn, "CREATE (x:XactCommit {foo: 'bar'}) return x")
      assert {:ok, rows} = books
      assert List.first(rows)["x"]["foo"] == "bar"
      assert String.length(conn.commit_url) > 0,
        "this is not an existing connection. Its commit_url, must not be empty"

      # Main connection should not see this new node.
      {:ok, results} = Neo4j.query(Neo4j.conn, "MATCH (x:XactCommit) RETURN x")
      assert is_list(results)
      assert Enum.count(results) == 0,
          "Main connection should not be able to see transactional change"

      # Now, commit...
      assert  {:ok, _} = Neo4j.tx_commit(conn)

      # And we should see it now with the main connection.
      {:ok, results} = Neo4j.query(Neo4j.conn, "MATCH (x:XactCommit) RETURN x")
      assert is_list(results)
      assert Enum.count(results) == 1
    after
      # Delete any XactCommit nodes that were succesfully committed!
      Neo4j.query(Neo4j.conn, "MATCH (x:XactCommit) DETACH DELETE x")
    end
  end

end
