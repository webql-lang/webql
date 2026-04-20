import webql/compiler
import webql/compiler/diagnostic
import webql/compiler/lexer/diagnostic as lexer_diagnostic
import webql/compiler/lexer/token
import webql/compiler/parser/diagnostic as parser_diagnostic
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/source

pub fn compile_resolves_module_test() {
  let source = "-> out: Int {}"
  let registry = registry.add_typename(registry.new(), "Int")
  let compiler = compiler.new(registry)

  let assert Ok(module) = compiler.compile(compiler, source)

  assert module
    == ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 8, end: 11),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 14),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 14),
    )
}

pub fn compile_wraps_lexer_diagnostic_test() {
  let compiler = compiler.new(registry.new())
  let assert Error(error) = compiler.compile(compiler, "!")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.LexerDiagnostic(lexer_diagnostic.IllegalToken),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_parser_diagnostic_test() {
  let compiler = compiler.new(registry.new())
  let assert Error(error) = compiler.compile(compiler, "{")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ParserDiagnostic(parser_diagnostic.UnexpectedToken(
        token.LBrace,
      )),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_resolver_diagnostic_test() {
  let source = "-> out: Int {}"
  let compiler = compiler.new(registry.new())

  let assert Error(error) = compiler.compile(compiler, source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownTypename(
        "Int",
      )),
      span: source.Span(start: 8, end: 11),
    )
}
