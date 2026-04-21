import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_module

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
