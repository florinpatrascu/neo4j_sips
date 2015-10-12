Neo4j.Sips
==========

A simple Elixir wrapper around the Neo4j graph database REST API. It is aiming to help Elixir developers to play with [Neo4j](http://neo4j.com/developer/get-started/), and to eventually become the main support for a future [Ecto](https://github.com/elixir-lang/ecto) adapter.

### Install

Edit mix.ex and add the `neo4j_sips` dependency to the `deps/1 `function:

    defp deps do
      [{:neo4j_sips, github: "florinpatrascu/neo4j_sips"}]
    end

Or, if you're using a local development copy:

    defp deps do
      [{:neo4j_sips, path: "../neo4j_sips"}]
    end

Then add the `neo4j_sips` dependency the applications list:

    def application do
      [applications: [:logger, :neo4j_sips]]
    end

Run `mix do deps.get, deps.compile`

Edit the `config/config.exs` and describe a Neo4j server endpoint, example:

    config :neo4j_sips, Neo4j,
      url: "http://localhost:7474"


If your server requires basic authentication, add this to your config file:
      
      basic_auth: [username: "foo", password: "bar"]
      
Or:
      
      token_auth: "bmVvNGo6dGVzdA==" # if using an authentication token?!
  
### Example

With a minimalist setup configured as above, and a Neo4j server running, we can connect to the server and run some queries using Elixir’s interactive shell ([IEx](http://elixir-lang.org/docs/stable/iex/IEx.html)):

    $ cd <my_mix_project>
    $ iex -S mix
    Erlang/OTP 18 [erts-7.1] [source] [64-bit] ....

    Interactive Elixir (1.1.1) - press Ctrl+C to exit ....
    iex(1)> alias Neo4j.Sips, as: Neo4j

    iex(2)> cypher = """
      CREATE (n:Neo4jSips {title:'Elixir sipping from Neo4j', released:2015, 
        license:'MIT', neo4j_sips_test: true})
    """

    iex(3)> Neo4j.query(Neo4j.conn, cypher)
    {:ok, []}

    iex(4)> n = Neo4j.query!(Neo4j.conn, "match (n:Neo4jSips {title:'Elixir sipping from Neo4j'}) where n.neo4j_sips_test return n")
    [%{"n" => %{"license" => "MIT", "neo4j_sips_test" => true, "released" => 2015,
         "title" => "Elixir sipping from Neo4j"}}]
    iex(5)> 
    

For more examples, see the test suites.

## License
* Neo4jSips - MIT, check LICENSE file for more information.
* Neo4j - Dual free software/commercial license, see http://neo4j.org/
