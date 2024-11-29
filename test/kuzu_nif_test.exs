defmodule KuzuNifTest do
  use ExUnit.Case
  doctest KuzuNif

  def reset_db do
    File.rm_rf("./kuzu.db")
  end

  def execute(query) do
    KuzuNif.run_query("./kuzu.db", query)
  end

  test "greets the world" do
    reset_db()

    # Create schema
    execute("CREATE NODE TABLE User(name STRING, age INT64, PRIMARY KEY (name))")
    execute("CREATE NODE TABLE City(name STRING, population INT64, PRIMARY KEY (name))")
    execute("CREATE REL TABLE Follows(FROM User TO User, since INT64)")
    execute("CREATE REL TABLE LivesIn(FROM User TO City)")

    # Insert data
    execute("COPY User FROM 'priv/csv/user.csv'")
    execute("COPY City FROM 'priv/csv/city.csv'")
    execute("COPY Follows FROM 'priv/csv/follows.csv'")
    execute("COPY LivesIn FROM 'priv/csv/lives-in.csv'")
    result = execute("MATCH (n) RETURN n.name, n.age, n.population;")

    IO.inspect(result)
  end
end
