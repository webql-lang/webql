import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_document

pub opaque type Resolver {
  Resolver(document: parser.Document)
}

/// Creates a new resolver instance from a parser document.
pub fn new(document: parser.Document) -> Resolver {
  Resolver(document:)
}

/// Resolves a resolver instance.
pub fn resolve(
  resolver: Resolver,
  environment: environment.Environment,
  context: context.Context,
) -> Result(#(hir.Document, context.Context), diagnostic.Diagnostic) {
  let reference = reference.Document(0)
  resolve_document.resolve(environment, context, resolver.document, reference)
}
