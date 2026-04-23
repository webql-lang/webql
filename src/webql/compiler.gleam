import gleam/dict
import gleam/list
import gleam/result
import webql/compiler/diagnostic
import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/resolver
import webql/compiler/resolver/ast as resolver_ast
import webql/compiler/resolver/schema

pub opaque type Compiler {
  Compiler(schema: schema.Schema)
}

/// Creates a compiler instance with resolver context.
pub fn new() -> Compiler {
  let schema = schema.new()
  Compiler(schema:)
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

  let resolver = resolver.new(module, compiler.schema)
  compile_resolve(resolver)
}

/// Adds a typename to the compiler instance.
pub fn add_typename(compiler: Compiler, typename: String) -> Compiler {
  Compiler(schema: schema.add_typename(compiler.schema, typename))
}

/// Adds typenames to the compiler instance.
pub fn add_typenames(compiler: Compiler, typenames: List(String)) -> Compiler {
  Compiler(schema: schema.add_typenames(compiler.schema, typenames))
}

/// Adds a node to the compiler instance.
pub fn add_node(compiler: Compiler, node: String) -> Compiler {
  Compiler(schema: schema.add_node(compiler.schema, node))
}

/// Adds nodes to the compiler instance.
pub fn add_nodes(compiler: Compiler, nodes: List(String)) -> Compiler {
  Compiler(schema: schema.add_nodes(compiler.schema, nodes))
}

/// Adds a typed input port to the compiler instance.
pub fn add_input(
  compiler: Compiler,
  node: String,
  input: #(String, String),
) -> Compiler {
  let #(name, typename) = input

  let input = case dict.get(compiler.schema.typenames, typename) {
    Ok(typename) -> #(name, typename)
    Error(_nil) -> #(name, schema.next_typename(compiler.schema))
  }

  case dict.get(compiler.schema.nodes, node) {
    Ok(node) -> {
      Compiler(schema: schema.add_input(compiler.schema, node, input))
    }

    Error(_nil) -> compiler
  }
}

/// Adds typed input ports to the compiler instance.
pub fn add_inputs(
  compiler: Compiler,
  node: String,
  inputs: List(#(String, String)),
) -> Compiler {
  list.fold(inputs, compiler, fn(compiler, input) {
    add_input(compiler, node, input)
  })
}

/// Adds a typed output port to the compiler instance.
pub fn add_output(
  compiler: Compiler,
  node: String,
  output: #(String, String),
) -> Compiler {
  let #(name, typename) = output

  let output = case dict.get(compiler.schema.typenames, typename) {
    Ok(typename) -> #(name, typename)
    Error(_nil) -> #(name, schema.next_typename(compiler.schema))
  }

  case dict.get(compiler.schema.nodes, node) {
    Ok(node) -> {
      Compiler(schema: schema.add_output(compiler.schema, node, output))
    }

    Error(_nil) -> compiler
  }
}

/// Adds typed output ports to the compiler instance.
pub fn add_outputs(
  compiler: Compiler,
  node: String,
  outputs: List(#(String, String)),
) -> Compiler {
  list.fold(outputs, compiler, fn(compiler, output) {
    add_output(compiler, node, output)
  })
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

fn compile_resolve(resolver: resolver.Resolver) {
  case resolver.resolve(resolver) {
    Ok(module) -> Ok(module)

    Error(error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.ResolverDiagnostic(error.kind),
        span: error.span,
      ))
  }
}
