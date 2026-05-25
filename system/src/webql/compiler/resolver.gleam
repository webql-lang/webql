import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_module

pub opaque type Resolver {
  Resolver(module: ast.Module)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: ast.Module) -> Resolver {
  Resolver(module:)
}

/// Resolves a resolver instance.
pub fn resolve(
  resolver: Resolver,
  environment: environment.Environment,
  context: context.Context,
) -> Result(#(hir.Module, context.Context), diagnostic.Diagnostic) {
  let reference = reference.Module(0)
  resolve_module.resolve(environment, context, resolver.module, reference)
}
