import gleam/result
import webql/graph
import webql/introspection/schema
import webql/lang/compiler/bootstrap
import webql/lang/compiler/context
import webql/lang/compiler/diagnostic
import webql/lang/compiler/environment
import webql/lang/compiler/lexer
import webql/lang/compiler/lowerer
import webql/lang/compiler/parser
import webql/lang/compiler/resolver
import webql/lang/compiler/typechecker

pub opaque type Compiler {
  Compiler(environment: environment.Environment)
}

/// Creates a compiler instance with resolver context.
pub fn new(schema: schema.Schema) -> Compiler {
  let environment = bootstrap.bootstrap(schema)
  Compiler(environment:)
}

/// Compiles a text source into a finalized module.
pub fn compile(
  compiler: Compiler,
  source: String,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  let context = context.new()

  let lexer = lexer.new(source)
  use tokens <- result.try(compile_lex(lexer))

  let parser = parser.new(source, tokens)
  use module <- result.try(compile_parse(parser))

  let resolver = resolver.new(module)
  use #(module, context) <- result.try(compile_resolve(
    compiler,
    context,
    resolver,
  ))

  let typechecker = typechecker.new(module)
  use module <- result.try(compile_typecheck(typechecker, context))

  let lowerer = lowerer.new(module)
  Ok(lowerer.lower(lowerer))
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

fn compile_resolve(
  compiler: Compiler,
  context: context.Context,
  resolver: resolver.Resolver,
) {
  case resolver.resolve(resolver, compiler.environment, context) {
    Ok(module) -> Ok(module)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.ResolverDiagnostic(error.kind),
        span: error.span,
      ))
  }
}

fn compile_typecheck(
  typechecker: typechecker.Typechecker,
  context: context.Context,
) {
  case typechecker.resolve(typechecker, context) {
    Ok(module) -> Ok(module)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.TypecheckerDiagnostic(error.kind),
        span: error.span,
      ))
  }
}
