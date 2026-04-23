import gleam/dict
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/primative
import webql/compiler/resolver/resolve_primitive
import webql/compiler/resolver/runtime
import webql/compiler/resolver/schema
import webql/compiler/source

/// Resolves an edge output.
pub fn resolve(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  output: parser_ast.Output,
) -> Result(ast.Output, diagnostic.Diagnostic) {
  case output {
    parser_ast.PortOutput(path:, span:) ->
      resolve_port_output(runtime, path, span)

    parser_ast.PrimitiveOutput(value:, span:) ->
      resolve_primitive_output(schema, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_port_output(
  runtime: runtime.Runtime,
  path: List(String),
  span: source.Span,
) {
  case dict.get(runtime.outputs, path) {
    Ok(reference) -> Ok(ast.PortOutput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}

fn resolve_primitive_output(
  schema: schema.Schema,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  let name = primative.get_typename(value)

  case dict.get(schema.typenames, name) {
    Ok(typename) -> {
      let value = resolve_primitive.resolve(value)
      Ok(ast.PrimitiveOutput(value:, typename:, span:))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownTypename(name), span:))
  }
}
