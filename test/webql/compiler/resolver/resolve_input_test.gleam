import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/resolve_input
import webql/compiler/resolver/runtime
import webql/compiler/source

pub fn resolve_port_input_test() {
  let runtime =
    runtime.add_input(runtime.new(), ["math", "in"], reference.Typename(0))

  let input_to_resolve =
    parser_ast.PortInput(
      path: ["math", "in"],
      span: source.Span(start: 0, end: 7),
    )

  let assert Ok(input) = resolve_input.resolve(runtime, input_to_resolve)

  assert input
    == ast.PortInput(
      path: ["math", "in"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_returns_unknown_input_for_missing_port_input_test() {
  let runtime = runtime.new()

  let input_to_resolve =
    parser_ast.PortInput(
      path: ["math", "in"],
      span: source.Span(start: 0, end: 7),
    )

  let assert Error(error) = resolve_input.resolve(runtime, input_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownInput(["math", "in"]),
      span: source.Span(start: 0, end: 7),
    )
}
