import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_primitive
import webql/compiler/runtime
import webql/compiler/schema
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
  case runtime.get_output(runtime, path) {
    Ok(#(reference, _typename)) -> Ok(ast.PortOutput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}

fn resolve_primitive_output(
  schema: schema.Schema,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  case schema.get_typename(schema, value.name) {
    Ok(typename) -> {
      let value = resolve_primitive.resolve(value)
      Ok(ast.PrimitiveOutput(value:, typename:, span:))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(value.name),
        span:,
      ))
  }
}
