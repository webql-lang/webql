import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_primitive
import webql/lang/compiler/source

/// Resolves an edge output.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  output: ast.Output,
) -> Result(hir.Output, diagnostic.Diagnostic) {
  case output {
    ast.PortOutput(path:, span:) -> resolve_port_output(context, path, span)

    ast.PrimitiveOutput(value:, span:) ->
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
    Ok(#(reference, _typename)) -> Ok(hir.PortOutput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}

fn resolve_primitive_output(
  environment: environment.Environment,
  value: ast.Primitive,
  span: source.Span,
) {
  case environment.get_typename(environment, value.name) {
    Ok(typename) -> {
      let value = resolve_primitive.resolve(value)
      Ok(hir.PrimitiveOutput(value:, typename:, span:))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(value.name),
        span:,
      ))
  }
}
