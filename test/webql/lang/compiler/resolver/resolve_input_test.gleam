import webql/lang/compiler/context
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_input
import webql/lang/compiler/source

pub fn resolve_port_input_test() {
  let context =
    context.add_input(context.new(), ["math", "in"], reference.Typename(0))

  let input_to_resolve =
    ast.PortInput(path: ["math", "in"], span: source.Span(start: 0, end: 7))

  let assert Ok(input) = resolve_input.resolve(context, input_to_resolve)

  assert input
    == hir.PortInput(
      path: ["math", "in"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_returns_unknown_input_for_missing_port_input_test() {
  let context = context.new()

  let input_to_resolve =
    ast.PortInput(path: ["math", "in"], span: source.Span(start: 0, end: 7))

  let assert Error(error) = resolve_input.resolve(context, input_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownInput(["math", "in"]),
      span: source.Span(start: 0, end: 7),
    )
}
