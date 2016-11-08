# Changelog

## v0.2.12 (2016-11-07)
- minor changes: dependencies update

## v0.2.11 (2016-09-29)
- fix access error bug. PR provided by @tpunt. Thank you.

## v0.2.10 (2016-07-24)
- Enhancements
    * ready for Elixir 1.3
    * Neo4j.Sips is paving the path towards an easier integration with third party frameworks i.e. where you may want to use Neo4j.Sips as an Ecto-like Repo, Adapters, etc.
    * you can enable the logger now and see the requests we send to the Neo4j server. Please see `config/test.exs`, for an example of logger configuration. For now the logged info is very simple simple, yet useful for debugging
    * added more tests
    * code cleanup and various code optimizations
- Breaking changes
    * you must start the `Neo4j.Sips` server process. This is easily done via: `Neo4j.Sips.start_link/1`. For example: `Neo4j.Sips.start_link(url: "http://localhost:7474")`
- Bug fixes
    * the driver configuration is properly reloaded
