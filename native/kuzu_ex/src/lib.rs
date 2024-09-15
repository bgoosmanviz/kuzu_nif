use rustler::{NifStruct, NifResult, NifTaggedEnum, Error};
use kuzu::{Connection, Database, SystemConfig, Value};

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
#[module = "KuzuNif.NodeVal"]
pub struct KuzuNifNodeVal {
    label: String,
    properties: Vec<(String, KuzuNifValue)>,
}

#[derive(NifStruct)]
#[module = "KuzuNif.RelVal"]
pub struct KuzuNifRelVal {
    label: String,
    properties: Vec<(String, KuzuNifValue)>,
}

#[derive(NifStruct)]
#[module = "KuzuNif.QueryResult"]
pub struct KuzuNifQueryResult {
    result: Vec<Vec<KuzuNifValue>>,
}

#[rustler::nif]
fn run_query(path: String, query: String) -> NifResult<KuzuNifQueryResult> {
    let config = SystemConfig::default();
    let db = Database::new(&path, config).map_err(|e| Error::Term(Box::new(format!("Failed to open database: {}", e))))?;
    let conn = Connection::new(&db).map_err(|e| Error::Term(Box::new(format!("Failed to create connection: {}", e))))?;
    let query_result = conn.query(&query).map_err(|e| Error::Term(Box::new(format!("Query failed: {}", e))))?;

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
