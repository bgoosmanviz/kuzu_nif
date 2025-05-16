# KuzuNif

Built by [Kineviz](https://kineviz.com).

**Very** **unfinished** attempt at adapting [KuzuDB's](https://github.com/kuzudb/kuzu) [Rust crate](https://docs.rs/kuzu/latest/kuzu/index.html) into [Elixir](https://elixir-lang.org/) via NIF, supported by the [Rustler](https://github.com/rusterlium/rustler) package. "Unfinished", because ideally we wouldn't open the database and connection in every call to `run_query`, but it works pretty well still. 🙂

See `native/kuzu_ex/src/lib.rs` for the NIF.

My solution involves copying the query result, which sounds kind of silly because ideally we'd take advantage of the underlying arrow format and do something akin to the [Explorer](https://github.com/elixir-explorer/explorer) package, which also [implements NIF in order to adapt Polars DataFrames](https://github.com/elixir-explorer/explorer/blob/main/native/explorer/src/dataframe/io.rs) into Elixir. KuzuDB's Rust crate's [QueryResult](https://docs.rs/kuzu/latest/kuzu/struct.QueryResult.html#) [supports arrow_array::arrow::RecordBatch](https://docs.rs/kuzu/latest/kuzu/struct.QueryResult.html#method.iter_arrow), but I couldn't figure out how to adapt it.

## Try it out

### Note about compiling the kuzu_nif Rust lib.

Note: to skip downloading the NIF and force a recompile, set env RUSTLER_PRECOMPILED_FORCE_BUILD=1. Requirements for building the Rust lib

- brew install cmake

### Run the tests

```
# Run the test. This takes a while to build.
# See test/kuzu_nif_test.exs
> mix test
Running ExUnit with seed: 706086, max_cases: 20

%{
  result: [
    [{:string, "Waterloo"}, {:null}, {:int64, 150000}],
    [{:string, "Kitchener"}, {:null}, {:int64, 200000}],
    [{:string, "Guelph"}, {:null}, {:int64, 75000}],
    [{:string, "Adam"}, {:int64, 30}, {:null}],
    [{:string, "Karissa"}, {:int64, 40}, {:null}],
    [{:string, "Zhang"}, {:int64, 50}, {:null}],
    [{:string, "Noura"}, {:int64, 25}, {:null}]
  ],
  __struct__: KuzuNif.QueryResult
}
.
Finished in 0.07 seconds (0.00s async, 0.07s sync)
1 test, 0 failures
```

There are some unused Rust deps from an attempt at adapting the Kuzu QueryResult into a Polars dataframe. They could be removed if needed.

## References

- https://mainmatter.com/blog/2023/02/01/using-rust-crates-in-elixir/
- https://stackoverflow.com/questions/78959357/convert-arrow-data-to-polars-dataframe
- https://stackoverflow.com/questions/78084066/arrow-recordbatch-as-polars-dataframe
- https://arrow.apache.org/rust/arrow_array/array/trait.Array.html#
- https://docs.rs/polars-arrow/0.43.1/polars_arrow/array/trait.Array.html#
- https://docs.rs/polars/latest/polars/series/struct.Series.html#method.from_arrow
- https://docs.rs/arrow-array/43.0.0/arrow_array/array/trait.Array.html
- https://docs.rs/kuzu/latest/kuzu/struct.QueryResult.html
- https://docs.rs/kuzu/latest/kuzu/struct.ArrowIterator.html
- https://docs.rs/kuzu/latest/kuzu/enum.Value.html
- [Discord thread in KuzuDB community](https://discord.com/channels/1196510116388806837/1281686605731463271)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kuzu_nif` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kuzu_nif, "~> 0.10.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kuzu_nif>.

## Release

This project uses the [rustler_precompiled](https://github.com/philss/rustler_precompiled) package to build the NIFs and avoid the need to compile the Rust crate locally.

To release a new version:

```
0. Update version in `mix.exs`, `README.md`, and `Cargo.toml`.
1. Commit a new tag. e.g. `v0.x.0`
2. `git push origin main --tags`
3. [Wait for all NIFs to be built](https://github.com/bgoosmanviz/kuzu_nif/actions)
4. `RUSTLER_PRECOMPILED_FORCE_BUILD=1 mix rustler_precompiled.download KuzuNif --all --print --ignore-unavailable`
5. `mix hex.publish`
6. Optional: commit and push the new checksum

Source: [Precompilation guide](https://hexdocs.pm/rustler_precompiled/precompilation_guide.html)
```

### About NIF Versions

https://github.com/rusterlium/rustler?tab=readme-ov-file#supported-nif-version
