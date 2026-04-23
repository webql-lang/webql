import gleam/bool
import gleam/dict
import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/runtime
import webql/compiler/resolver/schema
import webql/compiler/resolver/resolve_typename

/// Resolves an output field.
pub fn resolve(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  field: parser_ast.Return,
  reference: reference.Return,
) -> Result(ast.Return, diagnostic.Diagnostic) {
  let parser_ast.Return(name:, typename:, span:) = field

  use <- bool.guard(
    when: dict.has_key(runtime.returns, name),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(schema, typename))

  Ok(ast.Return(name:, typename:, reference:, span:))
}
