import gleam/result
import webql/typechecker
import webql/graph
import webql/lexer
import webql/lowerer
import webql/parser
import webql/resolver
import webql/schema
import webql/source

/// The compiler stage that rejected a WebQL document.
pub type DiagnosticKind {
  LexerDiagnostic(kind: lexer.DiagnosticKind)
  ParserDiagnostic(kind: parser.DiagnosticKind)
  ResolverDiagnostic(kind: resolver.DiagnosticKind)
  CheckerDiagnostic(kind: typechecker.DiagnosticKind)
}

/// A compilation error and the source span where it occurred.
pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// Compiles WebQL source into a graph.
pub fn compile(
  code: String,
  schema: schema.Schema,
) -> Result(graph.Graph, Diagnostic) {
  use tokens <- result.try(compile_lex(code))
  use ast <- result.try(compile_parse(code, tokens))
  use ast <- result.try(compile_resolve(ast, schema))
  use tast <- result.try(compile_check(ast))
  Ok(lowerer.lower(tast))
}

// PRIVATE FUNCTIONS
// =================
fn compile_lex(code: String) {
  case lexer.lex(code) {
    Ok(tokens) -> Ok(tokens)
    Error(diagnostic) ->
      Error(Diagnostic(
        kind: LexerDiagnostic(diagnostic.kind),
        span: diagnostic.span,
      ))
  }
}

fn compile_parse(code: String, tokens: List(lexer.Token)) {
  case parser.parse(code, tokens) {
    Ok(ast) -> Ok(ast)
    Error(diagnostic) ->
      Error(Diagnostic(
        kind: ParserDiagnostic(diagnostic.kind),
        span: diagnostic.span,
      ))
  }
}

fn compile_resolve(ast: parser.Ast, schema: schema.Schema) {
  case resolver.resolve(ast, schema) {
    Ok(ast) -> Ok(ast)
    Error(diagnostic) ->
      Error(Diagnostic(
        kind: ResolverDiagnostic(diagnostic.kind),
        span: diagnostic.span,
      ))
  }
}

fn compile_check(ast: resolver.Ast) {
  case typechecker.check(ast) {
    Ok(tast) -> Ok(tast)
    Error(diagnostic) ->
      Error(Diagnostic(
        kind: CheckerDiagnostic(diagnostic.kind),
        span: diagnostic.span,
      ))
  }
}
