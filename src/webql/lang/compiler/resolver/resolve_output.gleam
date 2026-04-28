import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_primitive
import webql/lang/compiler/source

/// Resolves an edge output.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  output: parser_ast.Output,
) -> Result(ast.Output, diagnostic.Diagnostic) {
  case output {
    parser_ast.PortOutput(path:, span:) ->
      resolve_port_output(context, path, span)

    parser_ast.PrimitiveOutput(value:, span:) ->
      resolve_primitive_output(environment, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_port_output(
  context: context.Context,
  path: List(String),
  span: source.Span,
) {
  case context.get_output(context, path) {
    Ok(#(reference, _typename)) -> Ok(ast.PortOutput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}

fn resolve_primitive_output(
  environment: environment.Environment,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  case environment.get_typename(environment, value.name) {
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
