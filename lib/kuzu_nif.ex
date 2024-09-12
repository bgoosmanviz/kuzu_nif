defmodule KuzuNif do
  use Rustler, otp_app: :kuzu_nif, crate: "kuzu_ex"

  def run_query(_path, _query), do: :erlang.nif_error(:nif_not_loaded)
end
