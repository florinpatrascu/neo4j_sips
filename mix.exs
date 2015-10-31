defmodule Neo4jSips.Mixfile do
  use Mix.Project

  @version "0.1.12"

  def project do
    [app: :neo4j_sips,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     package: package,
     description: "A very simple and versatile Neo4J Elixir driver",
     name: "Neo4j.Sips",
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
    [{:httpoison, "~> 0.7.4"},
     {:poison, "~> 1.5.0"},
     {:con_cache, "~> 0.9.0"},
     {:poolboy, "~> 1.5.1"},
     {:ex_doc, "~> 0.10.0", only: :docs},
     {:earmark, "~> 0.1.18", only: :docs},
     {:inch_ex, "~> 0.4.0", only: :docs}]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Florin T. Patrascu"],
      links: %{"GitHub" => "https://github.com/florinpatrascu/neo4j_sips"}}
  end
end
