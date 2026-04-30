import gleam/dict
import webql/document
import webql/introspection

pub fn introspect_empty_document_test() {
  assert introspection.introspect(
      document.Document(operators: dict.new(), typenames: []),
    )
    == introspection.Schema(operators: [], typenames: [])
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

  let introspection.Schema(operators:, typenames:) =
    introspection.introspect(document)
  let assert [operator] = operators

  assert typenames == ["Text"]
  assert operator
    == introspection.Operator(
      name: "Test",
      inputs: [introspection.Input(name: "input", typename: "Text")],
      outputs: [introspection.Output(name: "output", typename: "Text")],
    )
}
