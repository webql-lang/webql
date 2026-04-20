import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_output
import webql/compiler/source

pub fn resolve_port_output_test() {
  let registry = registry.add_output(registry.new(), ["math", "out"])

  let output_to_resolve =
    parser_ast.PortOutput(
      path: ["math", "out"],
      span: source.Span(start: 0, end: 8),
    )

  let assert Ok(output) = resolve_output.resolve(registry, output_to_resolve)

  assert output
    == ast.PortOutput(
      path: ["math", "out"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_returns_unknown_output_for_missing_port_output_test() {
  let registry = registry.new()

  let output_to_resolve =
    parser_ast.PortOutput(
      path: ["math", "out"],
      span: source.Span(start: 0, end: 8),
    )

  let assert Error(error) = resolve_output.resolve(registry, output_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownOutput(["math", "out"]),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_primitive_output_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let output_to_resolve =
    parser_ast.PrimitiveOutput(
      value: parser_ast.Int(value: 123, span: source.Span(start: 0, end: 3)),
      span: source.Span(start: 0, end: 3),
    )

  let assert Ok(output) = resolve_output.resolve(registry, output_to_resolve)

  assert output
    == ast.PrimitiveOutput(
      value: ast.Int(value: 123, span: source.Span(start: 0, end: 3)),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_primitive_output_typename_test() {
  let registry = registry.new()

  let output_to_resolve =
    parser_ast.PrimitiveOutput(
      value: parser_ast.Int(value: 123, span: source.Span(start: 0, end: 3)),
      span: source.Span(start: 0, end: 3),
    )

  let assert Error(error) = resolve_output.resolve(registry, output_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
