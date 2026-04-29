import gleam/dict
import webql/document
import webql/introspection
import webql/introspection/schema

pub fn introspect_empty_document_test() {
  assert introspection.introspect(
      document.Document(operators: dict.new(), typenames: []),
    )
    == schema.Schema(operators: [], typenames: [])
}

pub fn introspect_document_operator_test() {
  let document =
    document.Document(
      operators: dict.from_list([
        #(
          "Test",
          document.Operator(
            inputs: dict.from_list([
              #("input", document.Input(name: "input", typename: "Text")),
            ]),
            resolver: document.Resolver(resolver: fn(_inputs) { dict.new() }),
            outputs: dict.from_list([
              #("output", document.Output(name: "output", typename: "Text")),
            ]),
          ),
        ),
      ]),
      typenames: [document.Typename(name: "Text")],
    )

  let schema.Schema(operators:, typenames:) = introspection.introspect(document)
  let assert [operator] = operators

  assert typenames == ["Text"]
  assert operator
    == schema.Operator(
      name: "Test",
      inputs: [schema.Input(name: "input", typename: "Text")],
      outputs: [schema.Output(name: "output", typename: "Text")],
    )
}
