import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/resolve_module
import webql/compiler/resolver/runtime
import webql/compiler/resolver/schema

pub opaque type Resolver {
  Resolver(module: parser_ast.Module, schema: schema.Schema)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: parser_ast.Module, schema: schema.Schema) -> Resolver {
  Resolver(module:, schema:)
}

/// Resolves a resolver instance.
pub fn resolve(resolver: Resolver) -> Result(ast.Module, diagnostic.Diagnostic) {
  let reference = reference.Module(0)
  let runtime = runtime.new()

  resolve_module.resolve(resolver.schema, runtime, resolver.module, reference)
}
