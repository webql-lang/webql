import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_operation
import webql/lang/compiler/source

pub fn resolve_operation_resolves_body_test() {
  let schema = environment.add_typename(environment.new(), "Int")

  let operation_to_resolve =
    parser_ast.Operation(
      parameters: [
        parser_ast.Parameter(
          name: "in",
          typename: parser_ast.Typename(
            name: "Int",
            span: source.Span(start: 4, end: 7),
          ),
          span: source.Span(start: 0, end: 7),
        ),
      ],
      returns: [
        parser_ast.Return(
          name: "out",
          typename: parser_ast.Typename(
            name: "Int",
            span: source.Span(start: 15, end: 18),
          ),
          span: source.Span(start: 10, end: 18),
        ),
      ],
      definitions: [
        parser_ast.Definition(
          name: "Inner",
          operation: parser_ast.Operation(
            parameters: [],
            returns: [
              parser_ast.Return(
                name: "value",
                typename: parser_ast.Typename(
                  name: "Int",
                  span: source.Span(start: 35, end: 38),
                ),
                span: source.Span(start: 28, end: 38),
              ),
            ],
            definitions: [],
            bindings: [],
            edges: [],
            span: source.Span(start: 20, end: 41),
          ),
          span: source.Span(start: 20, end: 41),
        ),
      ],
      bindings: [
        parser_ast.Binding(
          name: "inner",
          value: parser_ast.NodeValue(
            name: "Inner",
            span: source.Span(start: 50, end: 55),
          ),
          span: source.Span(start: 42, end: 55),
        ),
      ],
      edges: [
        parser_ast.Edge(
          from: parser_ast.PortOutput(
            path: ["in"],
            span: source.Span(start: 54, end: 57),
          ),
          to: parser_ast.PortInput(
            path: ["out"],
            span: source.Span(start: 61, end: 65),
          ),
          span: source.Span(start: 54, end: 65),
        ),
      ],
      span: source.Span(start: 0, end: 67),
    )

  let assert Ok(#(operation, _context)) =
    resolve_operation.resolve(schema, context.new(), operation_to_resolve)

  assert operation
    == ast.Operation(
      parameters: [
        ast.Parameter(
          name: "in",
          typename: ast.Typename(
            name: "Int",
            reference: reference.Typename(0),
            span: source.Span(start: 4, end: 7),
          ),
          reference: reference.Parameter(0),
          span: source.Span(start: 0, end: 7),
        ),
      ],
      returns: [
        ast.Return(
          name: "out",
          typename: ast.Typename(
            name: "Int",
            reference: reference.Typename(0),
            span: source.Span(start: 15, end: 18),
          ),
          reference: reference.Return(0),
          span: source.Span(start: 10, end: 18),
        ),
      ],
      definitions: [
        ast.Definition(
          name: "Inner",
          operation: ast.Operation(
            parameters: [],
            returns: [
              ast.Return(
                name: "value",
                typename: ast.Typename(
                  name: "Int",
                  reference: reference.Typename(0),
                  span: source.Span(start: 35, end: 38),
                ),
                reference: reference.Return(0),
                span: source.Span(start: 28, end: 38),
              ),
            ],
            definitions: [],
            bindings: [],
            edges: [],
            span: source.Span(start: 20, end: 41),
          ),
          reference: reference.Definition(0),
          span: source.Span(start: 20, end: 41),
        ),
      ],
      bindings: [
        ast.Binding(
          name: "inner",
          value: ast.NodeValue(
            name: "Inner",
            reference: reference.Node(0),
            span: source.Span(start: 50, end: 55),
          ),
          reference: reference.Binding(0),
          span: source.Span(start: 42, end: 55),
        ),
      ],
      edges: [
        ast.Edge(
          from: ast.PortOutput(
            path: ["in"],
            reference: reference.Output(0),
            span: source.Span(start: 54, end: 57),
          ),
          to: ast.PortInput(
            path: ["out"],
            reference: reference.Input(0),
            span: source.Span(start: 61, end: 65),
          ),
          reference: reference.Edge(0),
          span: source.Span(start: 54, end: 65),
        ),
      ],
      span: source.Span(start: 0, end: 67),
    )
}

pub fn resolve_operation_returns_duplicate_definition_test() {
  let schema = environment.new()

  let operation_to_resolve =
    parser_ast.Operation(
      parameters: [],
      returns: [],
      definitions: [
        parser_ast.Definition(
          name: "Inner",
          operation: parser_ast.Operation(
            parameters: [],
            returns: [],
            definitions: [],
            bindings: [],
            edges: [],
            span: source.Span(start: 0, end: 0),
          ),
          span: source.Span(start: 0, end: 0),
        ),
        parser_ast.Definition(
          name: "Inner",
          operation: parser_ast.Operation(
            parameters: [],
            returns: [],
            definitions: [],
            bindings: [],
            edges: [],
            span: source.Span(start: 1, end: 1),
          ),
          span: source.Span(start: 1, end: 1),
        ),
      ],
      bindings: [],
      edges: [],
      span: source.Span(start: 0, end: 1),
    )

  let assert Error(error) =
    resolve_operation.resolve(schema, context.new(), operation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition("Inner"),
      span: source.Span(start: 1, end: 1),
    )
}

pub fn resolve_operation_returns_duplicate_edge_for_second_primitive_output_to_same_input_test() {
  let schema = environment.add_typename(environment.new(), "Int")

  let operation_to_resolve =
    parser_ast.Operation(
      parameters: [],
      returns: [
        parser_ast.Return(
          name: "out",
          typename: parser_ast.Typename(
            name: "Int",
            span: source.Span(start: 7, end: 10),
          ),
          span: source.Span(start: 2, end: 10),
        ),
      ],
      definitions: [],
      bindings: [],
      edges: [
        parser_ast.Edge(
          from: parser_ast.PrimitiveOutput(
            value: parser_ast.Int(
              name: "Int",
              value: 1,
              span: source.Span(start: 13, end: 14),
            ),
            span: source.Span(start: 13, end: 14),
          ),
          to: parser_ast.PortInput(
            path: ["out"],
            span: source.Span(start: 18, end: 22),
          ),
          span: source.Span(start: 13, end: 22),
        ),
        parser_ast.Edge(
          from: parser_ast.PrimitiveOutput(
            value: parser_ast.Int(
              name: "Int",
              value: 2,
              span: source.Span(start: 23, end: 24),
            ),
            span: source.Span(start: 23, end: 24),
          ),
          to: parser_ast.PortInput(
            path: ["out"],
            span: source.Span(start: 28, end: 32),
          ),
          span: source.Span(start: 23, end: 32),
        ),
      ],
      span: source.Span(start: 0, end: 34),
    )

  let assert Error(error) =
    resolve_operation.resolve(schema, context.new(), operation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(["out"]),
      span: source.Span(start: 23, end: 32),
    )
}
