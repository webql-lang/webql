import gleam/dict
import webql/document
import webql/introspection
import webql/introspection/schema

pub fn introspect_empty_document_test() {
  assert introspection.introspect(document.Document(operators: dict.new()))
    == schema.Schema(operators: dict.new())
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
    )

  let schema.Schema(operators:) = introspection.introspect(document)
  let assert Ok(operator) = dict.get(operators, "Test")

  assert operator
    == schema.Operator(
      name: "Test",
      inputs: [schema.Input(name: "input", typename: "Text")],
      outputs: [schema.Output(name: "output", typename: "Text")],
    )
}
