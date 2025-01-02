defmodule KuzuNif do
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :kuzu_nif,
    crate: "kuzu_ex",
    base_url:
      "https://github.com/bgoosmanviz/kuzu_nif/releases/download/v#{version}",
    force_build: System.get_env("RUSTLER_PRECOMPILED_FORCE_BUILD") in ["1", "true"],
    version: version,
    nif_versions: ["2.17"]

  @doc """
  Run a query on the Kuzu database at `path`.

  e.g.

  ```elixir
  {:ok, result} = KuzuNif.run_query("path/to/db", "MATCH (u:User) RETURN u.name, u.age")
  ```
  """
  def run_query(_path, _query), do: :erlang.nif_error(:nif_not_loaded)
end
