import webql/compiler/context
import webql/compiler/resolver/hir
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_module

pub opaque type Typechecker {
  Typechecker(module: hir.Module)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: hir.Module) -> Typechecker {
  Typechecker(module:)
}

/// Resolves a resolver instance.
pub fn resolve(
  typechecker: Typechecker,
  context: context.Context,
) -> Result(hir.Module, diagnostic.Diagnostic) {
  typecheck_module.typecheck(typechecker.module, context)
}
