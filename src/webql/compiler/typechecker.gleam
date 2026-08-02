import webql/compiler/context
import webql/compiler/resolver
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_document

pub opaque type Typechecker {
  Typechecker(document: resolver.Document)
}

/// Creates a new typechecker instance from a resolver document.
pub fn new(document: resolver.Document) -> Typechecker {
  Typechecker(document:)
}

/// Typechecks a resolver document.
pub fn resolve(
  typechecker: Typechecker,
  context: context.Context,
) -> Result(resolver.Document, diagnostic.Diagnostic) {
  typecheck_document.typecheck(typechecker.document, context)
}
