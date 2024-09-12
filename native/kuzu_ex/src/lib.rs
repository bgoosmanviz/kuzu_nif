use rustler::{NifResult, Error};
use kuzu::{Connection, Database, SystemConfig};

#[rustler::nif]
fn run_query(path: String, query: String) -> NifResult<String> {
    let config = SystemConfig::default();
    let db = match Database::new(&path, config) {
        Ok(db) => db,
        Err(e) => return Err(Error::Term(Box::new(format!("Failed to open database: {}", e))))
    };

    let conn = match Connection::new(&db) {
        Ok(conn) => conn,
        Err(e) => return Err(Error::Term(Box::new(format!("Failed to create connection: {}", e))))
    };

    let result = match conn.query(&query) {
        Ok(result) => result,
        Err(e) => return Err(Error::Term(Box::new(format!("Query failed: {}", e))))
    };

    for row in result {
        println!("{}", row[0]);
    }

    Ok("hi".to_string())
}

rustler::init!("Elixir.KuzuNif");
