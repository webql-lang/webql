import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_source
import webql/compiler/source

pub fn resolve_port_output_test() {
  let context =
    context.add_output(context.new(), ["math", "out"], reference.Port(0))

  let output_to_resolve =
    ast.Output(path: ["math", "out"], span: source.Span(start: 0, end: 8))

  let assert Ok(output) =
    resolve_source.resolve(environment.new(), context, output_to_resolve)

  assert output
    == hir.Output(
      path: ["math", "out"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_returns_unknown_output_for_missing_port_output_test() {
  let context = context.new()

  let output_to_resolve =
    ast.Output(path: ["math", "out"], span: source.Span(start: 0, end: 8))

  let assert Error(error) =
    resolve_source.resolve(environment.new(), context, output_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownOutput(["math", "out"]),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_value_output_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let output_to_resolve =
    ast.Static(
      value: ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Ok(output) =
    resolve_source.resolve(schema, context.new(), output_to_resolve)

  assert output
    == hir.Static(
      value: hir.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      port: reference.Port(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_value_output_port_test() {
  let schema = environment.new()

  let output_to_resolve =
    ast.Static(
      value: ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Error(error) =
    resolve_source.resolve(schema, context.new(), output_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownPort("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
