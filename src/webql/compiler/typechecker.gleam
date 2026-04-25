import webql/compiler/resolver/ast
import webql/compiler/runtime
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_module

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
  runtime: runtime.Runtime,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  typecheck_module.typecheck(typechecker.module, runtime)
}
