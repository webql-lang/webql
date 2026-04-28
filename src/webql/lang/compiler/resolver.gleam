import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_module
import webql/lang/loader/schema

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
  context: context.Context,
) -> Result(#(ast.Module, context.Context), diagnostic.Diagnostic) {
  let reference = reference.Module(0)
  resolve_module.resolve(
    environment.new(schema),
    context,
    resolver.module,
    reference,
  )
}
