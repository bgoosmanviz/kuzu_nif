defmodule KuzuNifTest do
  @path "./kuzudb"

  use ExUnit.Case

  def reset_db do
    File.rm_rf(@path)
  end

  test "greets the world" do
    reset_db()

    db = KuzuNif.create_database(@path)
    conn = KuzuNif.create_connection(db)
    # Create schema
    KuzuNif.query(conn, "CREATE NODE TABLE User(name STRING, age INT64, PRIMARY KEY (name))")
    KuzuNif.query(conn, "CREATE NODE TABLE City(name STRING, population INT64, PRIMARY KEY (name))")
    KuzuNif.query(conn, "CREATE REL TABLE Follows(FROM User TO User, since INT64)")
    KuzuNif.query(conn, "CREATE REL TABLE LivesIn(FROM User TO City)")

    # Insert data
    KuzuNif.query(conn, "COPY User FROM 'priv/csv/user.csv'")
    KuzuNif.query(conn, "COPY City FROM 'priv/csv/city.csv'")
    KuzuNif.query(conn, "COPY Follows FROM 'priv/csv/follows.csv'")
    KuzuNif.query(conn, "COPY LivesIn FROM 'priv/csv/lives-in.csv'")
    result = KuzuNif.query(conn, "MATCH (n) RETURN n.name, n.age, n.population;")

    IO.inspect(result)
  end
end
