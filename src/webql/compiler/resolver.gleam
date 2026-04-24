import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_module
import webql/compiler/runtime
import webql/compiler/schema

pub opaque type Resolver {
  Resolver(module: parser_ast.Module)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: parser_ast.Module) -> Resolver {
  Resolver(module:)
}

/// Resolves a resolver instance.
pub fn resolve(
  resolver: Resolver,
  schema: schema.Schema,
  runtime: runtime.Runtime,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  let reference = reference.Module(0)
  resolve_module.resolve(schema, runtime, resolver.module, reference)
}
