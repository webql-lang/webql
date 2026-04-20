import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_module

/// Resolves a parser module AST.
pub fn resolve(
  registry: registry.Registry,
  module: parser_ast.Module,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  let reference = reference.Module(0)
  resolve_module.resolve(registry, module, reference)
}
