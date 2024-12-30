defmodule KuzuNif do
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :kuzu_nif,
    crate: "kuzu_ex",
    base_url:
      "https://github.com/bgoosmanviz/kuzu_nif/releases/download/v#{version}",
    force_build: System.get_env("RUSTLER_PRECOMPILED_FORCE_BUILD") in ["1", "true"],
    version: version

  def run_query(_path, _query), do: :erlang.nif_error(:nif_not_loaded)
end
