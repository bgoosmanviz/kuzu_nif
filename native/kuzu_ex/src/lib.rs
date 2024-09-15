use rustler::{NifResult, Error};
use kuzu::{Connection, Database, SystemConfig};
use arrow_array::RecordBatch;
use arrow_array::{Array, StructArray};
use arrow_schema::DataType;
use polars::prelude::*;
use std::sync::Arc;


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

    let mut query_result = match conn.query(&query) {
        Ok(query_result) => query_result,
        Err(e) => return Err(Error::Term(Box::new(format!("Query failed: {}", e))))
    };

    // for row in query_result {
    //     println!("{:?}", row);
    // }


    fn record_batch_to_dataframe(batch: &RecordBatch) -> Result<DataFrame, PolarsError> {
        let schema = batch.schema();
        let mut columns = Vec::new();
    
        for (i, column) in batch.columns().iter().enumerate() {
            let field = schema.field(i);
            match field.data_type() {
                DataType::Struct(fields) => {
                    let struct_array = column.as_any().downcast_ref::<StructArray>().unwrap();
                    for (j, field) in fields.iter().enumerate() {
                        let name = format!("{}_{}", field.name(), field.name());
                        let array = struct_array.column(j);
                        let series = Series::try_from((name.as_str(), array.as_ref()))?;
                        columns.push(series);
                    }
                },
                _ => {
                    let name = field.name();
                    let series = Series::try_from((name, column.as_ref()))?;
                    columns.push(series);
                }
            }
        }
    
        DataFrame::new(columns)
    }

    let chunk_size = 1000; // Or whatever size you want
    match query_result.iter_arrow(chunk_size) {
        Ok(arrow_iterator) => {
            // Use the arrow_iterator here
            for chunk in arrow_iterator {
                // The chunk is already a RecordBatch, no need for additional matching
                // println!("Received a batch with {} rows", chunk.num_rows());
                // println!("Schema: {:?}", chunk.schema());
                match record_batch_to_dataframe(&chunk) {
                    Ok(df) => {
                        println!("Converted to DataFrame: {:?}", df);
                    },
                    Err(e) => {
                        println!("Error converting to DataFrame: {:?}", e);
                    }
                }
            }
        },
        Err(e) => {
            println!("Error creating ArrowIterator: {:?}", e);
        }
    }

    Ok("hi".to_string())
}

rustler::init!("Elixir.KuzuNif");
