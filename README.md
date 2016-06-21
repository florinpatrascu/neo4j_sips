Neo4j.Sips [![Deps Status](https://beta.hexfaktor.org/badge/all/github/florinpatrascu/neo4j_sips.svg)](https://beta.hexfaktor.org/github/florinpatrascu/neo4j_sips)
==========

A simple Elixir wrapper around the [Neo4j](http://neo4j.com/developer/get-started/) graph database REST API.

### Install

From [hex.pm](https://hex.pm/packages/neo4j_sips). Edit the `mix.ex` file and add the `neo4j_sips` dependency to the `deps/1 `function:

    defp deps do
      [{:neo4j_sips, "~> 0.1"}]
    end

or from Github:

    defp deps do
      [{:neo4j_sips, github: "florinpatrascu/neo4j_sips"}]
    end

If you're using a local development copy:

    defp deps do
      [{:neo4j_sips, path: "../neo4j_sips"}]
    end

Then add the `neo4j_sips` dependency the applications list:

    def application do
      [applications: [:logger, :neo4j_sips]]
    end


Edit the `config/config.exs` and describe a Neo4j server endpoint, example:

    config :neo4j_sips, Neo4j,
      url: "http://localhost:7474",
      pool_size: 5,
      max_overflow: 2,
      timeout: 30

Run `mix do deps.get, deps.compile`

If your server requires basic authentication, add this to your config file:
      
      basic_auth: [username: "foo", password: "bar"]
      
Or:
      
      token_auth: "bmVvNGo6dGVzdA==" # if using an authentication token?!
  
### Example

With a minimalist setup configured as above, and a Neo4j server running, we can connect to the server and run some queries using Elixir’s interactive shell ([IEx](http://elixir-lang.org/docs/stable/iex/IEx.html)):

    $ cd <my_mix_project>
    $ iex -S mix
    Erlang/OTP 18 [erts-7.2.1] [source] [64-bit] ...

    Interactive Elixir (1.2.3) - press Ctrl+C to exit (type h() ENTER for help)
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
  
    
For more examples, see the test suites.

### Contributing

- [Fork it](https://github.com/florinpatrascu/neo4j_sips/fork)
- Create your feature branch (`git checkout -b my-new-feature`)
- Test (`mix test`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create new Pull Request

### Author
Florin T.PATRASCU (@florinpatrascu)

## License
* Neo4j.Sips - MIT, check [LICENSE](LICENSE) file for more information.
* Neo4j - Dual free software/commercial license, see http://neo4j.org/
