defmodule Neo4jSips.Mixfile do
  use Mix.Project

  @version "0.1.25"

  def project do
    [app: :neo4j_sips,
     version: @version,
     elixir: "~> 1.2",
     deps: deps,
     package: package,
     description: "A very simple and versatile Neo4J Elixir driver",
     name: "Neo4j.Sips",

     # http://blog.plataformatec.com.br/2015/04/build-embedded-and-start-permanent-in-elixir-1-0-4/
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,

     docs: [extras: ["README.md"],
            source_ref: "v#{@version}",
            source_url: "https://github.com/florinpatrascu/neo4j_sips"]]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison, :poison, :con_cache],
     mod: {Neo4j.Sips, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison, "~> 2.0"},
     {:con_cache, "~> 0.11"},
     {:poolboy, "~> 1.5"},
     {:mix_test_watch, "~> 0.2", only: [:dev, :test]},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:ex_doc, "~> 0.11", only: :docs},
     {:earmark, "~> 0.2", only: :docs},
     {:inch_ex, "~> 0.5", only: :docs}]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Florin T. Patrascu"],
      links: %{"GitHub" => "https://github.com/florinpatrascu/neo4j_sips"}}
  end
end
