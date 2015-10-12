use Mix.Config

config :neo4j_sips, Neo4j,
  url: "http://localhost:7373",
  pool_size: 5,
  max_overflow: 2,
  #timeout: :infinity,
  timeout: 30,
  token_auth: "bmVvNGo6dGVzdA=="
  # basic_auth: [username: "neo4j", password: "test"]
