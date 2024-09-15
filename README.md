# KuzuNif

```
# Seed the database.
python main.py

# Run the test. This takes a while to build.
mix test
```

There are some unused Rust deps from an attempt at adapting the Kuzu QueryResult into a Polars dataframe. They could be removed if needed.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kuzu_nif` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kuzu_nif, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kuzu_nif>.

