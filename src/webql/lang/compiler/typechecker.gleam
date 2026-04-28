import webql/lang/compiler/context
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/typechecker/diagnostic
import webql/lang/compiler/typechecker/typecheck_module

pub opaque type Typechecker {
  Typechecker(module: ast.Module)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: ast.Module) -> Typechecker {
  Typechecker(module:)
}

/// Resolves a resolver instance.
pub fn resolve(
  typechecker: Typechecker,
  context: context.Context,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  typecheck_module.typecheck(typechecker.module, context)
}
