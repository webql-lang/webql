import gleam/dict
import gleam/dynamic
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
            parameters: dict.from_list([
              #("in", document.Parameter(name: "in", typename: "Text")),
            ]),
            resolver: document.Resolver(resolver: fn(_parameters) {
              dynamic.properties([])
            }),
            returns: dict.from_list([
              #("out", document.Return(name: "out", typename: "Text")),
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
      parameters: [introspection.Parameter(name: "in", typename: "Text")],
      returns: [introspection.Return(name: "out", typename: "Text")],
    )
}
