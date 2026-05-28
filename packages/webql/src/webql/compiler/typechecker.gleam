import webql/compiler/context
import webql/compiler/resolver/hir
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_document

pub opaque type Typechecker {
  Typechecker(document: hir.Document)
}

/// Creates a new typechecker instance from a resolver document.
pub fn new(document: hir.Document) -> Typechecker {
  Typechecker(document:)
}

/// Typechecks a resolver document.
pub fn resolve(
  typechecker: Typechecker,
  context: context.Context,
) -> Result(hir.Document, diagnostic.Diagnostic) {
  typecheck_document.typecheck(typechecker.document, context)
}
