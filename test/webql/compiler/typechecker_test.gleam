import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/compiler/typechecker

pub fn typecheck_accepts_matching_literal_edge_types_test() {
  let context = context.add_input(context.new(), ["string"], reference.Port(1))
  let document = document([], [literal_edge(reference.Port(1), ["string"])])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context) == Ok(document)
}

pub fn typecheck_rejects_mismatched_literal_edge_types_test() {
  let context = context.add_input(context.new(), ["string"], reference.Port(1))
  let document = document([], [literal_edge(reference.Port(0), ["string"])])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context)
    == Error(typechecker.Diagnostic(
      kind: typechecker.TypeMismatch(
        expected: reference.Port(1),
        found: reference.Port(0),
      ),
      span: source.Span(start: 0, end: 12),
    ))
}

pub fn typecheck_accepts_matching_port_edge_types_test() {
  let context =
    context.new()
    |> context.add_output(["math", "out"], reference.Port(0))
    |> context.add_input(["out"], reference.Port(0))

  let document = document([], [output_edge(["math", "out"], ["out"])])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context) == Ok(document)
}

pub fn typecheck_accepts_matching_nested_supernode_test() {
  let nested_context =
    context.add_input(context.new(), ["string"], reference.Port(1))

  let context =
    context.add_context(context.new(), reference.Supernode(0), nested_context)

  let edge = literal_edge(reference.Port(1), ["string"])
  let document = document([supernode([edge])], [])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context) == Ok(document)
}

pub fn typecheck_rejects_nested_supernode_mismatch_test() {
  let nested_context =
    context.add_input(context.new(), ["string"], reference.Port(1))

  let context =
    context.add_context(context.new(), reference.Supernode(0), nested_context)

  let edge = literal_edge(reference.Port(0), ["string"])
  let document = document([supernode([edge])], [])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context)
    == Error(typechecker.Diagnostic(
      kind: typechecker.TypeMismatch(
        expected: reference.Port(1),
        found: reference.Port(0),
      ),
      span: source.Span(start: 0, end: 12),
    ))
}

pub fn typecheck_rejects_unknown_supernode_test() {
  let document = document([supernode([])], [])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context.new())
    == Error(typechecker.Diagnostic(
      kind: typechecker.UnknownSupernode(reference.Supernode(0)),
      span: source.Span(start: 0, end: 12),
    ))
}

pub fn typecheck_rejects_unknown_input_test() {
  let document = document([], [literal_edge(reference.Port(0), ["missing"])])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context.new())
    == Error(typechecker.Diagnostic(
      kind: typechecker.UnknownInput(["missing"]),
      span: source.Span(start: 5, end: 12),
    ))
}

pub fn typecheck_rejects_unknown_output_test() {
  let context = context.add_input(context.new(), ["out"], reference.Port(0))
  let document = document([], [output_edge(["missing", "out"], ["out"])])
  let typechecker = typechecker.new(document)

  assert typechecker.resolve(typechecker, context)
    == Error(typechecker.Diagnostic(
      kind: typechecker.UnknownOutput(["missing", "out"]),
      span: source.Span(start: 0, end: 8),
    ))
}

fn document(
  nodes: List(resolver.Node),
  edges: List(resolver.Edge),
) -> resolver.Document {
  let span = source.Span(start: 0, end: 20)

  resolver.Document(
    graph: resolver.Graph(parameters: [], returns: [], nodes:, edges:, span:),
    reference: reference.Document(0),
    span:,
  )
}

fn supernode(edges: List(resolver.Edge)) -> resolver.Node {
  let span = source.Span(start: 0, end: 12)

  resolver.Supernode(
    name: "Inner",
    graph: resolver.Graph(parameters: [], returns: [], nodes: [], edges:, span:),
    reference: reference.Supernode(0),
    span:,
  )
}

fn literal_edge(
  port: reference.Port,
  target_path: List(String),
) -> resolver.Edge {
  resolver.Edge(
    source: resolver.Literal(
      value: resolver.Int(
        name: "Int",
        value: 1,
        span: source.Span(start: 0, end: 1),
      ),
      port:,
      span: source.Span(start: 0, end: 1),
    ),
    target: resolver.Input(
      path: target_path,
      reference: reference.Input(0),
      span: source.Span(start: 5, end: 12),
    ),
    reference: reference.Edge(0),
    span: source.Span(start: 0, end: 12),
  )
}

fn output_edge(
  source_path: List(String),
  target_path: List(String),
) -> resolver.Edge {
  resolver.Edge(
    source: resolver.Output(
      path: source_path,
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 8),
    ),
    target: resolver.Input(
      path: target_path,
      reference: reference.Input(0),
      span: source.Span(start: 12, end: 16),
    ),
    reference: reference.Edge(0),
    span: source.Span(start: 0, end: 16),
  )
}
