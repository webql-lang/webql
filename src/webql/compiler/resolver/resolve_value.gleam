import gleam/dict
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/primative
import webql/compiler/resolver/resolve_primitive
import webql/compiler/resolver/schema
import webql/compiler/source

/// Resolves a binding value.
pub fn resolve(
  schema: schema.Schema,
  value: parser_ast.Value,
) -> Result(ast.Value, diagnostic.Diagnostic) {
  case value {
    parser_ast.NodeValue(name:, span:) -> resolve_node_value(schema, name, span)

    parser_ast.PrimitiveValue(value:, span:) ->
      resolve_primitive_value(schema, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_node_value(schema: schema.Schema, name: String, span: source.Span) {
  case dict.get(schema.nodes, name) {
    Ok(reference) -> Ok(ast.NodeValue(name:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))
  }
}

fn resolve_primitive_value(
  schema: schema.Schema,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  let name = primative.get_typename(value)

  case dict.get(schema.typenames, name) {
    Ok(typename) -> {
      let value = resolve_primitive.resolve(value)
      Ok(ast.PrimitiveValue(value:, typename:, span:))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownTypename(name), span:))
  }
}
