## Neo4j.Sips

Simple Elixir driver wrapped around the [Neo4j](http://neo4j.com/developer/get-started/) graph database REST API. Compatible with the following Neo4j servers: `2.x/3.0.x/3.1.x`

![Build Status](https://travis-ci.org/florinpatrascu/neo4j_sips.svg?branch=master)[![Deps Status](https://beta.hexfaktor.org/badge/all/github/florinpatrascu/neo4j_sips.svg)](https://beta.hexfaktor.org/github/florinpatrascu/neo4j_sips)

Documentation: [hexdocs.pm/neo4j_sips/](http://hexdocs.pm/neo4j_sips/)

*You can also look at: [Bolt.Sips](https://github.com/florinpatrascu/bolt_sips), a similar driver but using Bolt, this time. Neo4j's newest network protocol, designed for high-performance. Cheers!*

### Install

[Available in Hex](https://hex.pm/packages/neo4j_sips). Edit the `mix.ex` file and add the `neo4j_sips` dependency to the `deps/1 `function:

    def deps do
      [{:neo4j_sips, "~> 0.2"}]
    end

or from Github:

    def deps do
      [{:neo4j_sips, github: "florinpatrascu/neo4j_sips"}]
    end

If you're using a local development copy:

    def deps do
      [{:neo4j_sips, path: "../neo4j_sips"}]
    end

Then add the `neo4j_sips` dependency the applications list:

    def application do
      [applications: [:logger, :neo4j_sips],
       mod: {Neo4j.Sips.Application, []}]
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

You can also specify the authentication in the `url` config:

      url: "http://neo4j:neo4j@localhost:7474"
  
### Example

With a minimalist setup configured as above, and a Neo4j server running, we can connect to the server and run some queries using Elixir’s interactive shell ([IEx](http://elixir-lang.org/docs/stable/iex/IEx.html)):

    $ cd <my_mix_project>
    $ iex -S mix
    Erlang/OTP 19 [erts-8.0.2] [source] [64-bit] ...

    Interactive Elixir (1.3.2) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> alias Neo4j.Sips, as: Neo4j

    iex(2)> Neo4j.start_link(url: "http://localhost:7474")
    {:ok, #PID<0.204.0>}

    iex(3)> cypher = """
      CREATE (n:Neo4jSips {title:'Elixir sipping from Neo4j', released:2015, 
        license:'MIT', neo4j_sips_test: true})
    """

    iex(4)> Neo4j.query(Neo4j.conn, cypher)
    {:ok, []}

    iex(5)> n = Neo4j.query!(Neo4j.conn, "match (n:Neo4jSips {title:'Elixir sipping from Neo4j'}) where n.neo4j_sips_test return n")
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

### Contributors

As reported by Github: [contributions to master, excluding merge commits](https://github.com/florinpatrascu/neo4j_sips/graphs/contributors)

### Author
Florin T.PATRASCU (@florinpatrascu, @florin on Twitter)

## License
* Neo4j.Sips - MIT, check [LICENSE](LICENSE) file for more information.
* Neo4j - Dual free software/commercial license, see http://neo4j.org/
