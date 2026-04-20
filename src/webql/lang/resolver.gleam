import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_module

pub opaque type Resolver {
  Resolver(module: parser_ast.Module, registry: registry.Registry)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: parser_ast.Module, registry: registry.Registry) -> Resolver {
  Resolver(module:, registry:)
}

/// Resolves a resolver instance.
pub fn resolve(resolver: Resolver) -> Result(ast.Module, diagnostic.Diagnostic) {
  let reference = reference.Module(0)
  resolve_module.resolve(resolver.registry, resolver.module, reference)
}
