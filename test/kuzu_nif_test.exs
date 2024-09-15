defmodule KuzuNifTest do
  use ExUnit.Case
  doctest KuzuNif

  test "greets the world" do
    result = KuzuNif.run_query(
      "./kuzu.db",
      "MATCH (n) RETURN n.name, n.age, n.population;"
    )
    IO.inspect(result)
  end
end
