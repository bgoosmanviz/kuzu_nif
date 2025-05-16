use rustler::{NifStruct, NifResult, NifTaggedEnum, Error, ResourceArc, Resource, resource_impl};
use kuzu::{Connection, Database, SystemConfig, Value};
use std::sync::{Arc, Mutex};

// Database resource type
pub struct DbResource(Arc<Mutex<Database>>);
#[resource_impl]
impl Resource for DbResource {}

// Connection resource type
pub struct ConnResource(Arc<Mutex<Connection<'static>>>);
#[resource_impl]
impl Resource for ConnResource {}

#[derive(NifTaggedEnum)]
pub enum KuzuNifValue {
    Null(),
    Bool(bool),
    Int64(i64),
    Int32(i32),
    Int16(i16),
    Int8(i8),
    UInt64(u64),
    UInt32(u32),
    UInt16(u16),
    UInt8(u8),
    Int128(i128),
    Double(f64),
    Float(f32),
    String(String),
}

#[derive(NifStruct)]
#[module = "KuzuNif.QueryResult"]
pub struct KuzuNifQueryResult {
    result: Vec<Vec<KuzuNifValue>>,
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn create_database(path: String) -> NifResult<ResourceArc<DbResource>> {
    let config = SystemConfig::default();
    let db = Database::new(&path, config)
        .map_err(|e| Error::Term(Box::new(format!("Failed to open database: {}", e))))?;
    Ok(ResourceArc::new(DbResource(Arc::new(Mutex::new(db)))))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn create_connection(db_arc: ResourceArc<DbResource>) -> NifResult<ResourceArc<ConnResource>> {
    let db_resource: &DbResource = &*db_arc;
    let db_guard = db_resource.0.lock().unwrap();
    let conn = Connection::new(&db_guard)
        .map_err(|e| Error::Term(Box::new(format!("Failed to create connection: {}", e))))?;
    // Store the connection in a static lifetime
    let conn = unsafe { std::mem::transmute(conn) };
    Ok(ResourceArc::new(ConnResource(Arc::new(Mutex::new(conn)))))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn query(conn_arc: ResourceArc<ConnResource>, cypher: String) -> NifResult<KuzuNifQueryResult> {
    let conn_resource: &ConnResource = &*conn_arc;
    let conn_guard = conn_resource.0.lock().unwrap();
    let query_result = conn_guard.query(&cypher)
        .map_err(|e| Error::Term(Box::new(format!("Query failed: {}", e))))?;

    let mut result = Vec::new();
    for row in query_result {
        let mut row_result = Vec::new();
        for value in row {
            let nif_value = match value {
                Value::Bool(b) => KuzuNifValue::Bool(b),
                Value::Int64(i) => KuzuNifValue::Int64(i),
                Value::Int32(i) => KuzuNifValue::Int32(i),
                Value::Int16(i) => KuzuNifValue::Int16(i),
                Value::Int8(i) => KuzuNifValue::Int8(i),
                Value::UInt64(u) => KuzuNifValue::UInt64(u),
                Value::UInt32(u) => KuzuNifValue::UInt32(u),
                Value::UInt16(u) => KuzuNifValue::UInt16(u),
                Value::UInt8(u) => KuzuNifValue::UInt8(u),
                Value::Int128(i) => KuzuNifValue::Int128(i),
                Value::Double(f) => KuzuNifValue::Double(f),
                Value::Float(f) => KuzuNifValue::Float(f),
                Value::String(s) => KuzuNifValue::String(s),
                Value::Null(_) => KuzuNifValue::Null(),
                _ => return Err(Error::Term(Box::new("Unsupported value type"))),
            };
            row_result.push(nif_value);
        }
        result.push(row_result);
    }

    Ok(KuzuNifQueryResult { result })
}

rustler::init!("Elixir.KuzuNif");
