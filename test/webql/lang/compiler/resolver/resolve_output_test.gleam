import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_output
import webql/lang/compiler/source

pub fn resolve_port_output_test() {
  let context =
    context.add_output(context.new(), ["math", "out"], reference.Typename(0))

  let output_to_resolve =
    ast.PortOutput(path: ["math", "out"], span: source.Span(start: 0, end: 8))

  let assert Ok(output) =
    resolve_output.resolve(environment.new(), context, output_to_resolve)

  assert output
    == hir.PortOutput(
      path: ["math", "out"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_returns_unknown_output_for_missing_port_output_test() {
  let context = context.new()

  let output_to_resolve =
    ast.PortOutput(path: ["math", "out"], span: source.Span(start: 0, end: 8))

  let assert Error(error) =
    resolve_output.resolve(environment.new(), context, output_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownOutput(["math", "out"]),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_primitive_output_test() {
  let schema = environment.add_typename(environment.new(), "Int")

  let output_to_resolve =
    ast.PrimitiveOutput(
      value: ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Ok(output) =
    resolve_output.resolve(schema, context.new(), output_to_resolve)

  assert output
    == hir.PrimitiveOutput(
      value: hir.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_primitive_output_typename_test() {
  let schema = environment.new()

  let output_to_resolve =
    ast.PrimitiveOutput(
      value: ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Error(error) =
    resolve_output.resolve(schema, context.new(), output_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
