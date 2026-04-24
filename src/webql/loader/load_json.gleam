import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import webql/loader/diagnostic
import webql/loader/schema

/// Decodes a JSON object and converts it into a schema.
///
/// ## Examples
///
///```json
///{
///  "typenames": ["Int"],
///  "nodes": [
///    {
///     "name": "Node",
///     "inputs": [{ "name": "value", "typename": "Int" }],
///     "outputs": [{ "name": "value", "typename": "Int" }]
///    }
///  ]
///}
/// ```
///
///     load_json.load("...")
pub fn load(from: String) -> Result(schema.Schema, diagnostic.Diagnostic) {
  let schema = schema.new()
  let decoder = load_schema(schema)

  case json.parse(from:, using: decoder) {
    Ok(schema) -> Ok(schema)
    Error(error) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.JsonDecodeError(error)))
  }
}

// PRIVATE FUNCTIONS
// =================
fn load_schema(schema: schema.Schema) {
  use typenames <- decode.field("typenames", decode.list(decode.string))
  use nodes <- decode.field("nodes", decode.list(load_node()))

  schema
  |> schema.add_typenames(typenames)
  |> add_nodes(nodes)
  |> decode.success()
}

fn load_node() {
  use name <- decode.field("name", decode.string)
  use inputs <- decode.field("inputs", decode.list(load_port()))
  use outputs <- decode.field("outputs", decode.list(load_port()))

  decode.success(#(name, inputs, outputs))
}

fn load_port() {
  use name <- decode.field("name", decode.string)
  use typename <- decode.field("typename", decode.string)
  decode.success(#(name, typename))
}

fn add_nodes(
  schema: schema.Schema,
  nodes: List(#(String, List(#(String, String)), List(#(String, String)))),
) {
  use schema, node <- list.fold(nodes, schema)
  let #(name, inputs, outputs) = node

  schema
  |> schema.add_node(name)
  |> add_inputs(name, inputs)
  |> add_outputs(name, outputs)
}

fn add_inputs(
  schema: schema.Schema,
  node: String,
  inputs: List(#(String, String)),
) {
  use schema, input <- list.fold(inputs, schema)
  let #(name, typename) = input

  let input = case dict.get(schema.typenames, typename) {
    Ok(typename) -> #(name, typename)
    Error(_nil) -> #(name, schema.next_typename(schema))
  }

  case dict.get(schema.nodes, node) {
    Ok(node) -> schema.add_input(schema, node, input)
    Error(_nil) -> schema
  }
}

fn add_outputs(
  schema: schema.Schema,
  node: String,
  outputs: List(#(String, String)),
) {
  use schema, output <- list.fold(outputs, schema)
  let #(name, typename) = output

  let output = case dict.get(schema.typenames, typename) {
    Ok(typename) -> #(name, typename)
    Error(_nil) -> #(name, schema.next_typename(schema))
  }

  case dict.get(schema.nodes, node) {
    Ok(node) -> schema.add_output(schema, node, output)
    Error(_nil) -> schema
  }
}
