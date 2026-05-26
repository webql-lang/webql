import gleam/dict
import gleam/dynamic
import webql/introspection
import webql/schema

pub fn introspect_empty_operations_test() {
  assert introspection.introspect(
      schema.Schema(operations: dict.new(), ports: []),
    )
    == introspection.Schema(operations: [], ports: [])
}

pub fn introspect_operations_operation_test() {
  let schema =
    schema.Schema(
      operations: dict.from_list([
        #(
          "Test",
          schema.Operation(
            inputs: dict.from_list([
              #("in", schema.Input(name: "in", port: "Text")),
            ]),
            resolver: schema.Resolver(resolver: fn(_parameters) {
              dynamic.properties([])
            }),
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
  assert introspection_schema.operations
    == [
      introspection.Operation(
        name: "Test",
        inputs: [introspection.Input(name: "in", port: "Text")],
        outputs: [introspection.Output(name: "out", port: "Text")],
      ),
    ]
}
