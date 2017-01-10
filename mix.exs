defmodule Neo4jSips.Mixfile do
  use Mix.Project

  @version "0.2.17"

  def project do
    [app: :neo4j_sips,
     version: @version,
     elixir: "~> 1.3",
     deps: deps(),
     package: package(),
     description: "A very simple and versatile Neo4J Elixir driver",
     name: "Neo4j.Sips",

     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,

     docs: [extras: ["README.md", "CHANGELOG.md"],
            source_ref: "v#{@version}",
            source_url: "https://github.com/florinpatrascu/neo4j_sips"]]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison, :poison, :con_cache, :poolboy],
     mod: {Neo4j.Sips.Application, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11"},
      {:poison, "~> 2.0 or ~> 3.0"},
      {:con_cache, "0.11.1"},
      {:poolboy, "~> 1.5"},
      {:mix_test_watch, "~> 0.2", only: [:dev, :test]},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.14.3", only: [:dev]}
    ]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Florin T. Patrascu"],
      links: %{"GitHub" => "https://github.com/florinpatrascu/neo4j_sips"}}
  end
end
