# mix test test/neo4j_sips_query_test.exs
defmodule Neo4j.Sips.Query.Test do
  use ExUnit.Case, async: true

  alias Neo4j.Sips, as: Neo4j

  setup_all do
    batch_cypher = """
      MATCH (n {neo4j_sips: TRUE}) OPTIONAL MATCH (n)-[r]-() DELETE n,r;

      CREATE (Neo4jSips:Neo4jSips {title:'Elixir sipping from Neo4j', released:2015, license:'MIT', neo4j_sips: true})
      CREATE (TNOTW:Book {title:'The Name of the Wind', released:2007, genre:'fantasy', neo4j_sips: true})
      CREATE (Patrick:Person {name:'Patrick Rothfuss', neo4j_sips: true})
      CREATE (Kvothe:Person {name:'Kote', neo4j_sips: true})
      CREATE (Denna:Person {name:'Denna', neo4j_sips: true})
      CREATE (Chandrian:Deamon {name:'Chandrian', neo4j_sips: true})

      CREATE
        (Kvothe)-[:ACTED_IN {roles:['sword fighter', 'magician', 'musician']}]->(TNOTW),
        (Denna)-[:ACTED_IN {roles:['many talents']}]->(TNOTW),
        (Chandrian)-[:ACTED_IN {roles:['killer']}]->(TNOTW),
        (Patrick)-[:WROTE]->(TNOTW)
    """
    assert {:ok, rows} = Neo4j.query(Neo4j.conn, String.split(batch_cypher, ";") # different command behavior in the same lot/batch
                         |> Enum.map(&(String.strip(&1)))
                         |> Enum.filter(&(String.length(&1) > 0)))
    refute length(rows) > 0, "Can't initialize the 'The Name of the Wind' database"
    :ok
  end

  test "a simple query that should work" do
    {:ok, row} = Neo4j.query(Neo4j.conn, "match (n:Person {neo4j_sips: true}) return n.name as Name limit 5")
    assert List.first(row)["Name"] == "Patrick Rothfuss",
           "missing 'The Name of the Wind' database, or data incomplete"
  end

  test "executing a Cypher query, with parameters" do
    cypher = "match (n:Person {neo4j_sips: true}) where n.name = {name} return n.name as name limit 1"
    case Neo4j.query(Neo4j.conn, cypher, %{name: "Kote"}) do
      {:ok, row} ->
        refute length(row) == 0, "Did you initialize the 'The Name of the Wind' database?"
        assert List.first(row)["name"] == "Kote", "expecting to find Kote"
      {:error, reason} -> IO.puts "Error: #{reason["message"]}"
    end
  end

  test "executing a raw Cypher query with alias, and no parameters" do
    cypher = """
      MATCH (p:Person {neo4j_sips: true})
      RETURN p, p.name AS name, upper(p.name) as NAME,
             coalesce(p.nickname,"n/a") AS nickname,
             { name: p.name, label:head(labels(p))} AS person
    """
    {:ok, r} = Neo4j.query(Neo4j.conn, cypher)

    if row = List.first(r) do
      assert row["name"] == "Patrick Rothfuss",
             "missing 'The Name of the Wind' database, or data incomplete"
      assert row["NAME"] == "PATRICK ROTHFUSS"
      assert row["nickname"] == "n/a"
      assert is_map(row["p"]), "was expecting a map `p`"
      assert row["p"]["neo4j_sips"] == true
      assert row["person"]["label"] == "Person"
    else
      IO.puts "Did you initialize the 'The Name of the Wind' database?"
    end
  end

  test "if Patrick Rothfuss wrote The Name of the Wind" do
    cypher = "MATCH (p:Person)-[r:WROTE]->(b:Book {title: 'The Name of the Wind'}) RETURN p LIMIT 1"
    rows = Neo4j.query!(Neo4j.conn, cypher)
    assert List.first(rows)["p"]["name"] == "Patrick Rothfuss"
  end

  test "it returns only known role names" do
    cypher = """
      MATCH (p)-[r:ACTED_IN]->() where p.neo4j_sips RETURN r.roles as roles
      LIMIT 25
    """
    rows = Neo4j.query!(Neo4j.conn, cypher)
    roles = ["killer", "sword fighter","magician","musician","many talents"]
    my_roles = Enum.map(rows, &(&1["roles"])) |> List.flatten
    assert my_roles -- roles == [], "found more roles in the db than expected"

  end


  test "query in a connection expecting results containing the graph data as well" do
    conn = Neo4j.conn( %{resultDataContents: [ "row", "graph" ]})
    {:ok, row: r, graph: g} = Neo4j.query(conn, "match (n:Person {neo4j_sips: true}) return n.name as Name limit 5")

    assert List.first(r)["Name"] == "Patrick Rothfuss",
           "missing 'The Name of the Wind' database, or data incomplete"

    assert length(List.first(g)["nodes"]) == 0," invalid 'graph' contents"
  end

end
