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
  Create a new Kuzu database at the specified path.

  Returns a resource that can be used to create connections.

  ## Examples

      db = KuzuNif.create_database("path/to/db")
  """
  def create_database(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Create a new connection to a Kuzu database.

  ## Examples

      conn = KuzuNif.create_connection(db)
  """
  def create_connection(_db), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Run a query using an existing connection.

  ## Examples

      result = KuzuNif.query(conn, "MATCH (u:User) RETURN u.name, u.age")
  """
  def query(_conn, _query), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Run a query using a new db and connection.

  ## Examples

      {:ok, result} = KuzuNif.run_query("path/to/db", "MATCH (u:User) RETURN u.name, u.age")
  """
  def run_query(path, query) do
    db = create_database(path)
    conn = create_connection(db)
    query(conn, query)
  end
end
