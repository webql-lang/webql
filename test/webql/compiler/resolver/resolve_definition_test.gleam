import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_definition
import webql/compiler/resolver/resolve_operation
import webql/compiler/runtime
import webql/compiler/source
import webql/loader/schema

pub fn resolve_definition_resolves_nested_operation_test() {
  let schema = schema.add_typename(schema.new(), "Int")

  let definition_to_resolve =
    parser_ast.Definition(
      name: "Inner",
      operation: parser_ast.Operation(
        parameters: [
          parser_ast.Parameter(
            name: "in",
            typename: parser_ast.Typename(
              name: "Int",
              span: source.Span(start: 15, end: 18),
            ),
            span: source.Span(start: 11, end: 18),
          ),
        ],
        returns: [
          parser_ast.Return(
            name: "out",
            typename: parser_ast.Typename(
              name: "Int",
              span: source.Span(start: 27, end: 30),
            ),
            span: source.Span(start: 22, end: 30),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [
          parser_ast.Edge(
            from: parser_ast.PortOutput(
              path: ["in"],
              span: source.Span(start: 34, end: 37),
            ),
            to: parser_ast.PortInput(
              path: ["out"],
              span: source.Span(start: 41, end: 45),
            ),
            span: source.Span(start: 34, end: 45),
          ),
        ],
        span: source.Span(start: 8, end: 47),
      ),
      span: source.Span(start: 0, end: 47),
    )

  let assert Ok(#(definition, _runtime)) =
    resolve_definition.resolve(
      schema,
      runtime.new(),
      definition_to_resolve,
      reference.Definition(0),
      resolve_operation.resolve_with_runtime,
    )

  assert definition
    == ast.Definition(
      name: "Inner",
      operation: ast.Operation(
        parameters: [
          ast.Parameter(
            name: "in",
            typename: ast.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 15, end: 18),
            ),
            reference: reference.Parameter(0),
            span: source.Span(start: 11, end: 18),
          ),
        ],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 27, end: 30),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 22, end: 30),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [
          ast.Edge(
            from: ast.PortOutput(
              path: ["in"],
              reference: reference.Output(0),
              span: source.Span(start: 34, end: 37),
            ),
            to: ast.PortInput(
              path: ["out"],
              reference: reference.Input(0),
              span: source.Span(start: 41, end: 45),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 34, end: 45),
          ),
        ],
        span: source.Span(start: 8, end: 47),
      ),
      reference: reference.Definition(0),
      span: source.Span(start: 0, end: 47),
    )
}

pub fn resolve_definition_returns_duplicate_definition_test() {
  let schema = schema.add_node(schema.new(), "Inner")

  let definition_to_resolve =
    parser_ast.Definition(
      name: "Inner",
      operation: parser_ast.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 8, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_definition.resolve(
      schema,
      runtime.new(),
      definition_to_resolve,
      reference.Definition(1),
      resolve_operation.resolve_with_runtime,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition("Inner"),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_definition_returns_duplicate_definition_for_schema_node_test() {
  let schema = schema.add_node(schema.new(), "Math")

  let definition_to_resolve =
    parser_ast.Definition(
      name: "Math",
      operation: parser_ast.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 7, end: 9),
      ),
      span: source.Span(start: 0, end: 9),
    )

  let assert Error(error) =
    resolve_definition.resolve(
      schema,
      runtime.new(),
      definition_to_resolve,
      reference.Definition(0),
      resolve_operation.resolve_with_runtime,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition("Math"),
      span: source.Span(start: 0, end: 9),
    )
}
