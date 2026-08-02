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
  let introspection.Schema(nodes:, ports:) = schema

  let environment =
    list.fold(nodes, environment.add_ports(environment.new(), ports), load_node)

  Compiler(environment:)
}

/// Compiles a text source into a finalized document.
pub fn compile(
  compiler: Compiler,
  source: String,
) -> Result(graph.Graph, diagnostic.Diagnostic) {
  let context = context.new()

  use tokens <- result.try(compile_lex(source))

  use document <- result.try(compile_parse(source, tokens))

  use #(document, context) <- result.try(compile_resolve(
    compiler,
    context,
    document,
  ))

  let typechecker = typechecker.new(document)
  use document <- result.try(compile_typecheck(typechecker, context))

  let lowerer = lowerer.new(document)
  Ok(lowerer.lower(lowerer))
}

// PRIVATE FUNCTIONS
// =================
fn load_node(
  environment: environment.Environment,
  node: introspection.Node,
) -> environment.Environment {
  let introspection.Node(name:, inputs:, outputs:) = node

  environment
  |> environment.add_node(name)
  |> load_parameters(name, inputs)
  |> load_returns(name, outputs)
}

fn load_parameters(
  environment: environment.Environment,
  node: String,
  inputs: List(introspection.Input),
) -> environment.Environment {
  use environment, input <- list.fold(inputs, environment)
  let introspection.Input(name:, port:) = input

  let environment = environment.add_port(environment, port)
  let node = environment.get_node(environment, node)
  let port = environment.get_port(environment, port)

  case node, port {
    Ok(node), Ok(port) ->
      environment.add_input(environment, node, #(name, port))

    _node, _port -> environment
  }
}

fn load_returns(
  environment: environment.Environment,
  node: String,
  outputs: List(introspection.Output),
) -> environment.Environment {
  use environment, output <- list.fold(outputs, environment)
  let introspection.Output(name:, port:) = output

  let environment = environment.add_port(environment, port)
  let node = environment.get_node(environment, node)
  let port = environment.get_port(environment, port)

  case node, port {
    Ok(node), Ok(port) ->
      environment.add_output(environment, node, #(name, port))

    _node, _port -> environment
  }
}

fn compile_lex(source: String) {
  case lexer.lex(source) {
    Ok(tokens) -> Ok(tokens)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.LexerDiagnostic(error.kind),
        span: error.span,
      ))
  }
}

fn compile_parse(source: String, tokens: List(lexer.Token)) {
  case parser.parse(source, tokens) {
    Ok(document) -> Ok(document)

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
  document: parser.Document,
) {
  case resolver.resolve(document, compiler.environment, context) {
    Ok(document) -> Ok(document)

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
    Ok(document) -> Ok(document)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.TypecheckerDiagnostic(error.kind),
        span: error.span,
      ))
  }
}
