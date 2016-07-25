# Changelog

## v0.2.10 (2016-07-24)
- Enhancements
    * ready for Elixir 1.3
    * Neo4j.Sips is paving the path towards an easier integration with third party frameworks i.e. where the end user may want to use Neo4j.Sips as a Ecto-like Recpo.
    * you can enable the logger now and see the requests we send to the Neo4j server. Please see `config/test.exs`, for an example of logger configuration
    * more tests
    * code cleanup and various code optimizations
- Breaking changes
    * you must start the `Neo4j.Sips` server process. This is easily done via: `Neo4j.Sips.start_link/1`. For example: `Neo4j.Sips.start_link(url: "http://localhost:7474")`
- Bug fixes
    * the driver configuration is properly reloaded
