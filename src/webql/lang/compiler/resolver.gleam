import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_module

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
