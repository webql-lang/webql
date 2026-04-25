import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/runtime
import webql/compiler/source
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_module

pub fn typecheck_accepts_matching_edge_types_test() {
  let runtime =
    runtime.add_input(runtime.new(), ["string"], reference.Typename(1))

  let module =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [
          ast.Edge(
            from: ast.PrimitiveOutput(
              value: ast.String(
                name: "String",
                value: "ok",
                span: source.Span(start: 0, end: 4),
              ),
              typename: reference.Typename(1),
              span: source.Span(start: 0, end: 4),
            ),
            to: ast.PortInput(
              path: ["string"],
              reference: reference.Input(0),
              span: source.Span(start: 8, end: 15),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 0, end: 15),
          ),
        ],
        span: source.Span(start: 0, end: 15),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 15),
    )

  assert typecheck_module.typecheck(module, runtime) == Ok(module)
}

pub fn typecheck_rejects_mismatched_edge_types_test() {
  let runtime =
    runtime.add_input(runtime.new(), ["string"], reference.Typename(1))

  let module =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [
          ast.Edge(
            from: ast.PrimitiveOutput(
              value: ast.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 0, end: 1),
              ),
              typename: reference.Typename(0),
              span: source.Span(start: 0, end: 1),
            ),
            to: ast.PortInput(
              path: ["string"],
              reference: reference.Input(0),
              span: source.Span(start: 5, end: 12),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 0, end: 12),
          ),
        ],
        span: source.Span(start: 0, end: 12),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 12),
    )

  let assert Error(error) = typecheck_module.typecheck(module, runtime)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypeMismatch(
        expected: reference.Typename(1),
        found: reference.Typename(0),
      ),
      span: source.Span(start: 0, end: 12),
    )
}

pub fn typecheck_rejects_nested_definition_mismatch_test() {
  let nested_runtime =
    runtime.add_input(runtime.new(), ["string"], reference.Typename(1))

  let runtime =
    runtime.add_runtime(runtime.new(), reference.Definition(0), nested_runtime)

  let module =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [],
        definitions: [
          ast.Definition(
            name: "Inner",
            operation: ast.Operation(
              parameters: [],
              returns: [],
              definitions: [],
              bindings: [],
              edges: [
                ast.Edge(
                  from: ast.PrimitiveOutput(
                    value: ast.Int(
                      name: "Int",
                      value: 1,
                      span: source.Span(start: 0, end: 1),
                    ),
                    typename: reference.Typename(0),
                    span: source.Span(start: 0, end: 1),
                  ),
                  to: ast.PortInput(
                    path: ["string"],
                    reference: reference.Input(0),
                    span: source.Span(start: 5, end: 12),
                  ),
                  reference: reference.Edge(0),
                  span: source.Span(start: 0, end: 12),
                ),
              ],
              span: source.Span(start: 0, end: 12),
            ),
            reference: reference.Definition(0),
            span: source.Span(start: 0, end: 12),
          ),
        ],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 12),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 12),
    )

  let assert Error(error) = typecheck_module.typecheck(module, runtime)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypeMismatch(
        expected: reference.Typename(1),
        found: reference.Typename(0),
      ),
      span: source.Span(start: 0, end: 12),
    )
}

pub fn typecheck_accepts_matching_nested_definition_test() {
  let nested_runtime =
    runtime.add_input(runtime.new(), ["string"], reference.Typename(1))

  let runtime =
    runtime.add_runtime(runtime.new(), reference.Definition(0), nested_runtime)

  let module =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [],
        definitions: [
          ast.Definition(
            name: "Inner",
            operation: ast.Operation(
              parameters: [],
              returns: [],
              definitions: [],
              bindings: [],
              edges: [
                ast.Edge(
                  from: ast.PrimitiveOutput(
                    value: ast.String(
                      name: "String",
                      value: "ok",
                      span: source.Span(start: 0, end: 4),
                    ),
                    typename: reference.Typename(1),
                    span: source.Span(start: 0, end: 4),
                  ),
                  to: ast.PortInput(
                    path: ["string"],
                    reference: reference.Input(0),
                    span: source.Span(start: 8, end: 15),
                  ),
                  reference: reference.Edge(0),
                  span: source.Span(start: 0, end: 15),
                ),
              ],
              span: source.Span(start: 0, end: 15),
            ),
            reference: reference.Definition(0),
            span: source.Span(start: 0, end: 15),
          ),
        ],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 15),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 15),
    )

  assert typecheck_module.typecheck(module, runtime) == Ok(module)
}
