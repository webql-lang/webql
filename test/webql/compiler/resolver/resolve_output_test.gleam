import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_output
import webql/compiler/runtime
import webql/compiler/source
import webql/loader/schema

pub fn resolve_port_output_test() {
  let runtime =
    runtime.add_output(runtime.new(), ["math", "out"], reference.Typename(0))

  let output_to_resolve =
    parser_ast.PortOutput(
      path: ["math", "out"],
      span: source.Span(start: 0, end: 8),
    )

  let assert Ok(output) =
    resolve_output.resolve(
      environment.new(schema.new()),
      runtime,
      output_to_resolve,
    )

  assert output
    == ast.PortOutput(
      path: ["math", "out"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_returns_unknown_output_for_missing_port_output_test() {
  let runtime = runtime.new()

  let output_to_resolve =
    parser_ast.PortOutput(
      path: ["math", "out"],
      span: source.Span(start: 0, end: 8),
    )

  let assert Error(error) =
    resolve_output.resolve(
      environment.new(schema.new()),
      runtime,
      output_to_resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownOutput(["math", "out"]),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_primitive_output_test() {
  let schema = schema.add_typename(schema.new(), "Int")

  let output_to_resolve =
    parser_ast.PrimitiveOutput(
      value: parser_ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Ok(output) =
    resolve_output.resolve(
      environment.new(schema),
      runtime.new(),
      output_to_resolve,
    )

  assert output
    == ast.PrimitiveOutput(
      value: ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_primitive_output_typename_test() {
  let schema = schema.new()

  let output_to_resolve =
    parser_ast.PrimitiveOutput(
      value: parser_ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Error(error) =
    resolve_output.resolve(
      environment.new(schema),
      runtime.new(),
      output_to_resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
