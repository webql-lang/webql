import webql/compiler
import webql/compiler/diagnostic
import webql/compiler/lexer/diagnostic as lexer_diagnostic
import webql/compiler/lexer/token
import webql/compiler/parser/diagnostic as parser_diagnostic
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/source

pub fn compile_wraps_lexer_diagnostic_test() {
  let compiler = compiler.new()
  let assert Error(error) = compiler.compile(compiler, "!")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.LexerDiagnostic(lexer_diagnostic.IllegalToken),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_parser_diagnostic_test() {
  let compiler = compiler.new()
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
  let compiler = compiler.new()

  let assert Error(error) = compiler.compile(compiler, source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownTypename(
        "Int",
      )),
      span: source.Span(start: 8, end: 11),
    )
}
