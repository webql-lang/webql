import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/resolver/reference

pub type Schema {
  Schema(
    inputs: dict.Dict(reference.Node, List(#(String, reference.Typename))),
    nodes: dict.Dict(String, reference.Node),
    outputs: dict.Dict(reference.Node, List(#(String, reference.Typename))),
    typenames: dict.Dict(String, reference.Typename),
  )
}

/// Creates a new schema.
pub fn new() -> Schema {
  Schema(
    inputs: dict.new(),
    nodes: dict.new(),
    outputs: dict.new(),
    typenames: dict.new(),
  )
}

/// Adds typenames to the current schema instance.
pub fn add_typename(schema: Schema, typename: String) -> Schema {
  let Schema(typenames:, ..) = schema

  Schema(
    ..schema,
    typenames: dict.upsert(typenames, typename, fn(typename) {
      case typename {
        option.Some(typename) -> typename
        option.None -> next_typename(schema)
      }
    }),
  )
}

/// Adds typenames to the current schema instance.
pub fn add_typenames(schema: Schema, typenames: List(String)) -> Schema {
  list.fold(typenames, schema, add_typename)
}

/// Adds nodes to the current schema instance.
pub fn add_node(schema: Schema, node: String) -> Schema {
  let Schema(nodes:, ..) = schema

  Schema(
    ..schema,
    nodes: dict.upsert(nodes, node, fn(node) {
      case node {
        option.Some(node) -> node
        option.None -> next_node(schema)
      }
    }),
  )
}

/// Adds nodes to the current schema instance.
pub fn add_nodes(schema: Schema, nodes: List(String)) -> Schema {
  list.fold(nodes, schema, add_node)
}

/// Adds typed input ports to the current schema instance.
pub fn add_input(
  schema: Schema,
  node: reference.Node,
  input: #(String, reference.Typename),
) -> Schema {
  let Schema(inputs:, ..) = schema

  Schema(
    ..schema,
    inputs: dict.upsert(inputs, node, fn(existing) {
      case existing {
        option.Some(existing) -> list.append(existing, [input])
        option.None -> [input]
      }
    }),
  )
}

/// Adds typed input ports to the current schema instance.
pub fn add_inputs(
  schema: Schema,
  node: reference.Node,
  inputs: List(#(String, reference.Typename)),
) -> Schema {
  list.fold(inputs, schema, fn(schema, input) { add_input(schema, node, input) })
}

/// Adds typed output ports to the current schema instance.
pub fn add_output(
  schema: Schema,
  node: reference.Node,
  output: #(String, reference.Typename),
) -> Schema {
  let Schema(outputs:, ..) = schema

  Schema(
    ..schema,
    outputs: dict.upsert(outputs, node, fn(existing) {
      case existing {
        option.Some(existing) -> list.append(existing, [output])
        option.None -> [output]
      }
    }),
  )
}

/// Adds typed output ports to the current schema instance.
pub fn add_outputs(
  schema: Schema,
  node: reference.Node,
  outputs: List(#(String, reference.Typename)),
) -> Schema {
  list.fold(outputs, schema, fn(schema, output) {
    add_output(schema, node, output)
  })
}

/// Gets the next stable typename reference.
pub fn next_typename(schema: Schema) -> reference.Typename {
  reference.Typename(dict.size(schema.typenames))
}

/// Gets the next stable node reference.
pub fn next_node(schema: Schema) -> reference.Node {
  reference.Node(dict.size(schema.nodes))
}

/// Looks up typed input ports for a node.
pub fn get_inputs(
  schema: Schema,
  node: reference.Node,
) -> Result(List(#(String, reference.Typename)), Nil) {
  dict.get(schema.inputs, node)
}

/// Looks up a node reference by name.
pub fn get_node(schema: Schema, node: String) -> Result(reference.Node, Nil) {
  dict.get(schema.nodes, node)
}

/// Looks up typed output ports for a node.
pub fn get_outputs(
  schema: Schema,
  node: reference.Node,
) -> Result(List(#(String, reference.Typename)), Nil) {
  dict.get(schema.outputs, node)
}

/// Looks up a typename reference by name.
pub fn get_typename(
  schema: Schema,
  typename: String,
) -> Result(reference.Typename, Nil) {
  dict.get(schema.typenames, typename)
}
