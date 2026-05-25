import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_module

pub fn typecheck_accepts_matching_edge_types_test() {
  let context =
    context.add_input(context.new(), ["string"], reference.Typename(1))

  let module =
    hir.Module(
      operation: hir.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [
          hir.Edge(
            from: hir.PrimitiveOutput(
              value: hir.String(
                name: "String",
                value: "ok",
                span: source.Span(start: 0, end: 4),
              ),
              typename: reference.Typename(1),
              span: source.Span(start: 0, end: 4),
            ),
            to: hir.PortInput(
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

  assert typecheck_module.typecheck(module, context) == Ok(module)
}

pub fn typecheck_rejects_mismatched_edge_types_test() {
  let context =
    context.add_input(context.new(), ["string"], reference.Typename(1))

  let module =
    hir.Module(
      operation: hir.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [
          hir.Edge(
            from: hir.PrimitiveOutput(
              value: hir.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 0, end: 1),
              ),
              typename: reference.Typename(0),
              span: source.Span(start: 0, end: 1),
            ),
            to: hir.PortInput(
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

  let assert Error(error) = typecheck_module.typecheck(module, context)

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
  let nested_context =
    context.add_input(context.new(), ["string"], reference.Typename(1))

  let context =
    context.add_context(context.new(), reference.Definition(0), nested_context)

  let module =
    hir.Module(
      operation: hir.Operation(
        parameters: [],
        returns: [],
        definitions: [
          hir.Definition(
            name: "Inner",
            operation: hir.Operation(
              parameters: [],
              returns: [],
              definitions: [],
              bindings: [],
              edges: [
                hir.Edge(
                  from: hir.PrimitiveOutput(
                    value: hir.Int(
                      name: "Int",
                      value: 1,
                      span: source.Span(start: 0, end: 1),
                    ),
                    typename: reference.Typename(0),
                    span: source.Span(start: 0, end: 1),
                  ),
                  to: hir.PortInput(
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

  let assert Error(error) = typecheck_module.typecheck(module, context)

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
  let nested_context =
    context.add_input(context.new(), ["string"], reference.Typename(1))

  let context =
    context.add_context(context.new(), reference.Definition(0), nested_context)

  let module =
    hir.Module(
      operation: hir.Operation(
        parameters: [],
        returns: [],
        definitions: [
          hir.Definition(
            name: "Inner",
            operation: hir.Operation(
              parameters: [],
              returns: [],
              definitions: [],
              bindings: [],
              edges: [
                hir.Edge(
                  from: hir.PrimitiveOutput(
                    value: hir.String(
                      name: "String",
                      value: "ok",
                      span: source.Span(start: 0, end: 4),
                    ),
                    typename: reference.Typename(1),
                    span: source.Span(start: 0, end: 4),
                  ),
                  to: hir.PortInput(
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

  assert typecheck_module.typecheck(module, context) == Ok(module)
}
