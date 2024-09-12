defmodule KuzuNifTest do
  use ExUnit.Case
  doctest KuzuNif

  test "greets the world" do
    result = KuzuNif.run_query(
      "./kuzu.db",
      "RETURN 1;"
    )
    IO.inspect(result)
  end
end
