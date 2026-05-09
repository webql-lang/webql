import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_definition
import webql/lang/compiler/resolver/resolve_operation
import webql/lang/compiler/source

pub fn resolve_definition_resolves_nested_operation_test() {
  let schema = environment.add_typename(environment.new(), "Int")

  let definition_to_resolve =
    ast.Definition(
      name: "Inner",
      operation: ast.Operation(
        parameters: [
          ast.Parameter(
            name: "in",
            typename: ast.Typename(
              name: "Int",
              span: source.Span(start: 15, end: 18),
            ),
            span: source.Span(start: 11, end: 18),
          ),
        ],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              span: source.Span(start: 27, end: 30),
            ),
            span: source.Span(start: 22, end: 30),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [
          ast.Edge(
            from: ast.PortOutput(
              path: ["in"],
              span: source.Span(start: 34, end: 37),
            ),
            to: ast.PortInput(
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

  let assert Ok(#(definition, _context)) =
    resolve_definition.resolve(
      schema,
      context.new(),
      definition_to_resolve,
      reference.Definition(0),
      resolve_operation.resolve,
    )

  assert definition
    == hir.Definition(
      name: "Inner",
      operation: hir.Operation(
        parameters: [
          hir.Parameter(
            name: "in",
            typename: hir.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 15, end: 18),
            ),
            reference: reference.Parameter(0),
            span: source.Span(start: 11, end: 18),
          ),
        ],
        returns: [
          hir.Return(
            name: "out",
            typename: hir.Typename(
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
          hir.Edge(
            from: hir.PortOutput(
              path: ["in"],
              reference: reference.Output(0),
              span: source.Span(start: 34, end: 37),
            ),
            to: hir.PortInput(
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
  let schema = environment.add_node(environment.new(), "Inner")

  let definition_to_resolve =
    ast.Definition(
      name: "Inner",
      operation: ast.Operation(
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
      context.new(),
      definition_to_resolve,
      reference.Definition(1),
      resolve_operation.resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition("Inner"),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_definition_returns_duplicate_definition_for_schema_node_test() {
  let schema = environment.add_node(environment.new(), "Math")

  let definition_to_resolve =
    ast.Definition(
      name: "Math",
      operation: ast.Operation(
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
      context.new(),
      definition_to_resolve,
      reference.Definition(0),
      resolve_operation.resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition("Math"),
      span: source.Span(start: 0, end: 9),
    )
}
