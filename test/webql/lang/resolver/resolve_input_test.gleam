import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_input
import webql/lang/source

pub fn resolve_port_input_test() {
  let registry = registry.add_input(registry.new(), ["math", "in"])

  let input_to_resolve =
    parser_ast.PortInput(
      path: ["math", "in"],
      span: source.Span(start: 0, end: 7),
    )

  let assert Ok(input) = resolve_input.resolve(registry, input_to_resolve)

  assert input
    == ast.PortInput(
      path: ["math", "in"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_returns_unknown_input_for_missing_port_input_test() {
  let registry = registry.new()

  let input_to_resolve =
    parser_ast.PortInput(
      path: ["math", "in"],
      span: source.Span(start: 0, end: 7),
    )

  let assert Error(error) = resolve_input.resolve(registry, input_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownInput(["math", "in"]),
      span: source.Span(start: 0, end: 7),
    )
}
