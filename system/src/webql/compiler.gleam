import gleam/list
import gleam/result
import webql/compiler/context
import webql/compiler/diagnostic
import webql/compiler/environment
import webql/compiler/lexer
import webql/compiler/lowerer
import webql/compiler/parser
import webql/compiler/resolver
import webql/compiler/typechecker
import webql/graph
import webql/introspection

pub opaque type Compiler {
  Compiler(environment: environment.Environment)
}

/// Creates a compiler instance with resolver context.
pub fn new(schema: introspection.Schema) -> Compiler {
  let introspection.Schema(operations:, ports:) = schema

  let environment =
    list.fold(
      operations,
      environment.add_typenames(environment.new(), ports),
      load_operation,
    )

  Compiler(environment:)
}

/// Compiles a text source into a finalized module.
pub fn compile(
  compiler: Compiler,
  source: String,
) -> Result(graph.Graph, diagnostic.Diagnostic) {
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
fn load_operation(
  environment: environment.Environment,
  operation: introspection.Operation,
) -> environment.Environment {
  let introspection.Operation(name:, inputs:, outputs:) = operation

  environment
  |> environment.add_node(name)
  |> load_parameters(name, inputs)
  |> load_returns(name, outputs)
}

fn load_parameters(
  environment: environment.Environment,
  operation: String,
  inputs: List(introspection.Input),
) -> environment.Environment {
  use environment, input <- list.fold(inputs, environment)
  let introspection.Input(name:, port:) = input

  let environment = environment.add_typename(environment, port)
  let node = environment.get_node(environment, operation)
  let typename = environment.get_typename(environment, port)

  case node, typename {
    Ok(node), Ok(typename) ->
      environment.add_input(environment, node, #(name, typename))

    _node, _typename -> environment
  }
}

fn load_returns(
  environment: environment.Environment,
  operation: String,
  outputs: List(introspection.Output),
) -> environment.Environment {
  use environment, output <- list.fold(outputs, environment)
  let introspection.Output(name:, port:) = output

  let environment = environment.add_typename(environment, port)
  let node = environment.get_node(environment, operation)
  let typename = environment.get_typename(environment, port)

  case node, typename {
    Ok(node), Ok(typename) ->
      environment.add_output(environment, node, #(name, typename))

    _node, _typename -> environment
  }
}

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
