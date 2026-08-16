import gleam/bool
import gleam/list
import gleam/result
import webql/resolver
import webql/source

/// A typed WebQL AST.
pub type Tast {
  Tast(ast: resolver.Ast)
}

/// A semantic error and the syntax span where it occurred.
pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// The kind of error encountered while checking a resolved graph.
pub type DiagnosticKind {
  TypeMismatch(expected: resolver.Typename, found: resolver.Typename)
}

/// Checks a resolved syntax tree for semantic errors.
pub fn check(ast: resolver.Ast) -> Result(Tast, Diagnostic) {
  use _ok <- result.try(list.try_each(ast.supernodes, check_supernode))
  use _ok <- result.try(list.try_each(ast.boundaries, check_boundary))
  use _ok <- result.try(list.try_each(ast.edges, check_edge))

  Ok(Tast(ast))
}

// PRIVATE FUNCTIONS
// =================
fn check_supernode(supernode: resolver.Supernode) {
  use _tast <- result.try(check(supernode.ast))
  Ok(Nil)
}

fn check_boundary(boundary: resolver.Boundary) {
  check_from(boundary.from, boundary.typename, boundary.span)
}

fn check_edge(edge: resolver.Edge) {
  check_from(edge.from, edge.to.typename, edge.span)
}

fn check_from(
  from: resolver.From,
  expected: resolver.Typename,
  span: source.Span,
) {
  let found = case from {
    resolver.Output(typename:, ..) -> typename

    resolver.Literal(value: resolver.Int(..), ..) -> resolver.Typename("Int")

    resolver.Literal(value: resolver.Float(..), ..) ->
      resolver.Typename("Float")

    resolver.Literal(value: resolver.String(..), ..) ->
      resolver.Typename("String")
  }

  use <- bool.guard(when: found == expected, return: Ok(Nil))
  Error(Diagnostic(kind: TypeMismatch(expected:, found:), span:))
}
