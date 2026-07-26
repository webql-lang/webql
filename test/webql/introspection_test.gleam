import gleam/dict
import webql
import webql/introspection
import webql/schema

pub fn introspect_empty_nodes_test() {
  assert introspection.introspect(schema.Schema(nodes: dict.new(), ports: []))
    == introspection.Schema(nodes: [], ports: [])
}

pub fn introspect_schema_through_public_api_test() {
  assert webql.introspect(schema.Schema(nodes: dict.new(), ports: []))
    == introspection.Schema(nodes: [], ports: [])
}

pub fn introspect_nodes_test() {
  let schema =
    schema.Schema(
      nodes: dict.from_list([
        #(
          "Test",
          schema.Node(
            inputs: dict.from_list([
              #("in", schema.Input(name: "in", port: "Text")),
            ]),
            outputs: dict.from_list([
              #("out", schema.Output(name: "out", port: "Text")),
            ]),
          ),
        ),
      ]),
      ports: [schema.Port(name: "Text")],
    )

  let introspection_schema = introspection.introspect(schema)

  assert introspection_schema.ports == ["Text"]
  assert introspection_schema.nodes
    == [
      introspection.Node(
        name: "Test",
        inputs: [introspection.Input(name: "in", port: "Text")],
        outputs: [introspection.Output(name: "out", port: "Text")],
      ),
    ]
}
