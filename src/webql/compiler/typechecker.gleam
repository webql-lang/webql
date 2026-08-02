import gleam/result
import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source

pub type DiagnosticKind {
  UnknownSupernode(reference: reference.Supernode)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  TypeMismatch(expected: reference.Port, found: reference.Port)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

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
) -> Result(resolver.Document, Diagnostic) {
  typecheck_document(typechecker.document, context)
}

// PRIVATE FUNCTIONS
// =================
fn typecheck_document(
  document: resolver.Document,
  context: context.Context,
) -> Result(resolver.Document, Diagnostic) {
  use _ok <- result.try(typecheck_graph(context, document.graph))
  Ok(document)
}

fn typecheck_graph(context: context.Context, graph: resolver.Graph) {
  use _ok <- result.try(typecheck_supernodes(context, graph.nodes))
  typecheck_edges(context, graph.edges)
}

fn typecheck_supernodes(context: context.Context, nodes: List(resolver.Node)) {
  case nodes {
    [resolver.Supernode(reference:, graph:, span:, ..), ..rest] -> {
      use nested_context <- result.try(get_context(context, reference, span))

      use _ok <- result.try(typecheck_graph(nested_context, graph))
      typecheck_supernodes(context, rest)
    }

    [resolver.Node(..), ..rest] -> typecheck_supernodes(context, rest)

    [] -> Ok(Nil)
  }
}

fn get_context(context: context.Context, reference, span) {
  case context.get_context(context, reference) {
    Ok(context) -> Ok(context)
    Error(_error) -> Error(Diagnostic(kind: UnknownSupernode(reference), span:))
  }
}

fn typecheck_edges(context: context.Context, edges: List(resolver.Edge)) {
  case edges {
    [edge, ..rest] -> {
      use _ok <- result.try(typecheck_edge(edge, context))
      typecheck_edges(context, rest)
    }

    [] -> Ok(Nil)
  }
}

fn typecheck_edge(
  edge: resolver.Edge,
  context: context.Context,
) -> Result(Nil, Diagnostic) {
  let resolver.Edge(source:, target:, span:, ..) = edge
  use expected <- result.try(get_port_target(context, target))
  use found <- result.try(get_port_source(context, source))

  case expected, found {
    expected, found if expected == found -> Ok(Nil)
    _expected, _found ->
      Error(Diagnostic(kind: TypeMismatch(expected:, found:), span:))
  }
}

fn get_port_source(context: context.Context, source: resolver.Source) {
  case source {
    resolver.Output(path:, span:, ..) -> {
      use #(_reference, port) <- result.try(get_output(context, path, span))
      Ok(port)
    }

    resolver.Literal(port:, ..) -> Ok(port)
  }
}

fn get_port_target(context: context.Context, target: resolver.Target) {
  let resolver.Input(path:, span:, ..) = target

  use #(_reference, port) <- result.try(get_input(context, path, span))
  Ok(port)
}

fn get_input(context: context.Context, path: List(String), span) {
  case context.get_input(context, path) {
    Ok(input) -> Ok(input)
    Error(_error) -> Error(Diagnostic(kind: UnknownInput(path), span:))
  }
}

fn get_output(context: context.Context, path: List(String), span) {
  case context.get_output(context, path) {
    Ok(output) -> Ok(output)
    Error(_error) -> Error(Diagnostic(kind: UnknownOutput(path), span:))
  }
}
