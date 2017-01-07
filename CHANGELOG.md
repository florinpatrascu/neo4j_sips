# Changelog

## v0.2.16 (2017-01-07)
- Travis test builds with Elixir 1.3/1.4
- tame some of the warnings and mild code refactoring
- updated README

## v0.2.15 (2017-01-05)
- add Travis CI support
- temporarily suspending the `Neo4j.Sips.Server.Test` suite; requires more thinking, after the url refactoring
- Elixir 1.3
- return an error if the driver authentication fails

## v0.2.14 (2016-12-26)
- Neo4j 3.1 is now returning the address of the `Bolt` protocol address, during the initial handshake, with the remote http API. At this time, I am expecting a set of keys I convert later to atoms, for efficiency. However, the story with the atoms in Erlang is well-known: `Atoms are not garbage-collected. Once an atom is created, it will never be removed.` This is why I also had to make sure I am allocating all the keys I need **before** this initial handshake. And the `:bolt` atom was not one of them, as I didn't expect to have it, breaking this way the Poison validations. Fixed now.

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
