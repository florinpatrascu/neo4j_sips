defmodule Neo4jSips.Mixfile do
  use Mix.Project

  @version "0.1.5"

  def project do
    [app: :neo4j_sips,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     package: package,
     description: "A very simple and versatile Neo4J Elixir driver",
     name: "Neo4j.Sips",
     docs: [extras: ["README.md"], main: "README",
            source_ref: "v#{@version}",
            source_url: "https://github.com/florinpatrascu/neo4j_sips"]]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :httpoison, :con_cache],
     mod: {Neo4j.Sips, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.7"},
     {:poison, "~> 1.4.0"},
     {:con_cache, "~> 0.9.0"},
     {:poolboy, "~> 1.5"},
     {:ex_doc, "~> 0.7", only: :docs},
     {:earmark, "~> 0.1", only: :docs},
     {:inch_ex, only: :docs}]
  end

  defp package do
    %{licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/florinpatrascu/neo4j_sips"}}
  end
end
