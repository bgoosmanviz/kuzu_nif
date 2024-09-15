import kuzu

def main() -> None:
    # Create an empty on-disk database and connect to it
    db = kuzu.Database("./kuzu.db")
    conn = kuzu.Connection(db)

    # Create schema
    conn.execute("CREATE NODE TABLE User(name STRING, age INT64, PRIMARY KEY (name))")
    conn.execute("CREATE NODE TABLE City(name STRING, population INT64, PRIMARY KEY (name))")
    conn.execute("CREATE REL TABLE Follows(FROM User TO User, since INT64)")
    conn.execute("CREATE REL TABLE LivesIn(FROM User TO City)")

    # Insert data
    conn.execute('COPY User FROM "./priv/csv/user.csv"')
    conn.execute('COPY City FROM "./priv/csv/city.csv"')
    conn.execute('COPY Follows FROM "./priv/csv/follows.csv"')
    conn.execute('COPY LivesIn FROM "./priv/csv/lives-in.csv"')

    # Execute Cypher query
    response = conn.execute(
        """
        MATCH (a:User)-[f:Follows]->(b:User)
        RETURN a.name, b.name, f.since;
        """
    )
    while response.has_next():
        print(response.get_next())

main()