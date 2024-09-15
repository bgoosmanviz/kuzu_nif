defmodule KuzuNifTest do
  use ExUnit.Case
  doctest KuzuNif

  test "greets the world" do
    result = KuzuNif.run_query(
      "./kuzu.db",
      "MATCH (n)-[r]-(m) RETURN n, r, m;"
    )
    IO.inspect(result)
  end
end
