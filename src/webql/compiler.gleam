import gleam/result
import webql/compiler/diagnostic
import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/resolver
import webql/compiler/resolver/ast as resolver_ast
import webql/compiler/runtime
import webql/compiler/schema

pub opaque type Compiler {
  Compiler(schema: schema.Schema, runtime: runtime.Runtime)
}

/// Creates a compiler instance with resolver context.
pub fn new() -> Compiler {
  let schema = schema.new()
  let runtime = runtime.new()

  Compiler(schema:, runtime:)
}

/// Compiles a text source into a finalized module.
pub fn compile(
  compiler: Compiler,
  source: String,
) -> Result(resolver_ast.Module, diagnostic.Diagnostic) {
  let lexer = lexer.new(source)
  use tokens <- result.try(compile_lex(lexer))

  let parser = parser.new(source, tokens)
  use module <- result.try(compile_parse(parser))

  let resolver = resolver.new(module)
  compile_resolve(compiler, resolver)
}

// PRIVATE FUNCTIONS
// =================
fn compile_lex(lexer: lexer.Lexer) {
  case lexer.lex(lexer) {
    Ok(tokens) -> Ok(tokens)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.LexerDiagnostic(error.kind),
        span: error.span,
      ))
  }
}

fn compile_parse(parser: parser.Parser) {
  case parser.parse(parser) {
    Ok(module) -> Ok(module)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.ParserDiagnostic(error.kind),
        span: error.span,
      ))
  }
}

fn compile_resolve(compiler: Compiler, resolver: resolver.Resolver) {
  case resolver.resolve(resolver, compiler.schema, compiler.runtime) {
    Ok(module) -> Ok(module)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.ResolverDiagnostic(error.kind),
        span: error.span,
      ))
  }
}
