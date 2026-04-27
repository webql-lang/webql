import gleam/dict
import gleam/list
import webql/loader/schema

/// Builds a schema from literal nodes and typenames.
pub fn build(
  typenames: List(String),
  nodes: List(#(String, List(#(String, String)), List(#(String, String)))),
) -> schema.Schema {
  let schema = schema.new()

  schema
  |> schema.add_typenames(typenames)
  |> build_nodes(nodes)
}

// PRIVATE FUNCTIONS
// =================
fn build_nodes(
  schema: schema.Schema,
  nodes: List(#(String, List(#(String, String)), List(#(String, String)))),
) {
  use schema, node <- list.fold(nodes, schema)
  let #(name, inputs, outputs) = node

  schema
  |> schema.add_node(name)
  |> build_inputs(name, inputs)
  |> build_outputs(name, outputs)
}

fn build_inputs(
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

  case schema.get_node(schema, node) {
    Ok(node) -> schema.add_input(schema, node, input)
    Error(_nil) -> schema
  }
}

fn build_outputs(
  schema: schema.Schema,
  node: String,
  outputs: List(#(String, String)),
) {
  use schema, output <- list.fold(outputs, schema)
  let #(name, typename) = output

  let output = case schema.get_typename(schema, typename) {
    Ok(typename) -> #(name, typename)
    Error(_nil) -> #(name, schema.next_typename(schema))
  }

  case schema.get_node(schema, node) {
    Ok(node) -> schema.add_output(schema, node, output)
    Error(_nil) -> schema
  }
}
