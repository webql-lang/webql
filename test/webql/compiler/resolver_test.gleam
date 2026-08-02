import webql/compiler/context
import webql/compiler/environment
import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source

pub fn resolve_complete_graph_and_register_context_test() {
  let document_source =
    "input: Int -> output: Int, float: Float, text: String, number: Int { "
    <> "Inner = value: Int -> result: Int { .value -> .result } "
    <> "inner = Inner math = Math "
    <> ".input -> math.left math.value -> .output "
    <> "1.5 -> .float \"hello\" -> .text 7 -> .number }"

  let assert Ok(#(document, resolved_context)) =
    resolve_source(document_source, test_environment(), context.new())

  let assert resolver.Document(
    reference: reference.Document(0),
    span: source.Span(start: 0, end: 238),
    graph: resolver.Graph(
      parameters: [
        resolver.Parameter(
          name: "input",
          port: resolver.Port(name: "Int", reference: reference.Port(0), ..),
          reference: reference.Parameter(0),
          ..,
        ),
      ],
      returns: [
        resolver.Return(
          name: "output",
          port: resolver.Port(name: "Int", reference: reference.Port(0), ..),
          reference: reference.Return(0),
          ..,
        ),
        resolver.Return(
          name: "float",
          port: resolver.Port(name: "Float", reference: reference.Port(1), ..),
          reference: reference.Return(1),
          ..,
        ),
        resolver.Return(
          name: "text",
          port: resolver.Port(name: "String", reference: reference.Port(2), ..),
          reference: reference.Return(2),
          ..,
        ),
        resolver.Return(
          name: "number",
          port: resolver.Port(name: "Int", reference: reference.Port(0), ..),
          reference: reference.Return(3),
          ..,
        ),
      ],
      nodes: [
        resolver.Supernode(
          name: "Inner",
          graph: inner_graph,
          reference: reference.Supernode(0),
          ..,
        ),
        resolver.Node(
          name: "inner",
          node: "Inner",
          reference: reference.Node(0),
          ..,
        ),
        resolver.Node(
          name: "math",
          node: "Math",
          reference: reference.Node(1),
          ..,
        ),
      ],
      edges: [
        resolver.Edge(
          source: resolver.Output(
            path: ["input"],
            reference: reference.Output(0),
            ..,
          ),
          target: resolver.Input(
            path: ["math", "left"],
            reference: reference.Input(5),
            ..,
          ),
          reference: reference.Edge(0),
          ..,
        ),
        resolver.Edge(
          source: resolver.Output(
            path: ["math", "value"],
            reference: reference.Output(2),
            ..,
          ),
          target: resolver.Input(
            path: ["output"],
            reference: reference.Input(0),
            ..,
          ),
          reference: reference.Edge(1),
          ..,
        ),
        resolver.Edge(
          source: resolver.Literal(
            value: resolver.Float(name: "Float", value: 1.5, ..),
            port: reference.Port(1),
            ..,
          ),
          target: resolver.Input(
            path: ["float"],
            reference: reference.Input(1),
            ..,
          ),
          reference: reference.Edge(2),
          ..,
        ),
        resolver.Edge(
          source: resolver.Literal(
            value: resolver.String(name: "String", value: "hello", ..),
            port: reference.Port(2),
            ..,
          ),
          target: resolver.Input(
            path: ["text"],
            reference: reference.Input(2),
            ..,
          ),
          reference: reference.Edge(3),
          ..,
        ),
        resolver.Edge(
          source: resolver.Literal(
            value: resolver.Int(name: "Int", value: 7, ..),
            port: reference.Port(0),
            ..,
          ),
          target: resolver.Input(
            path: ["number"],
            reference: reference.Input(3),
            ..,
          ),
          reference: reference.Edge(4),
          ..,
        ),
      ],
      span: source.Span(start: 0, end: 238),
    ),
  ) = document

  let assert resolver.Graph(
    parameters: [
      resolver.Parameter(
        name: "value",
        port: resolver.Port(name: "Int", reference: reference.Port(0), ..),
        reference: reference.Parameter(0),
        ..,
      ),
    ],
    returns: [
      resolver.Return(
        name: "result",
        port: resolver.Port(name: "Int", reference: reference.Port(0), ..),
        reference: reference.Return(0),
        ..,
      ),
    ],
    edges: [
      resolver.Edge(
        source: resolver.Output(
          path: ["value"],
          reference: reference.Output(0),
          ..,
        ),
        target: resolver.Input(
          path: ["result"],
          reference: reference.Input(0),
          ..,
        ),
        reference: reference.Edge(0),
        ..,
      ),
    ],
    ..,
  ) = inner_graph

  assert context.get_parameter(resolved_context, "input")
    == Ok(reference.Parameter(0))
  assert context.get_output(resolved_context, ["input"])
    == Ok(#(reference.Output(0), reference.Port(0)))

  assert context.get_return(resolved_context, "output")
    == Ok(reference.Return(0))
  assert context.get_input(resolved_context, ["output"])
    == Ok(#(reference.Input(0), reference.Port(0)))

  assert context.get_supernode(resolved_context, "Inner")
    == Ok(reference.Supernode(0))
  let assert Ok(inner_context) =
    context.get_context(resolved_context, reference.Supernode(0))
  assert context.get_parameter(inner_context, "value")
    == Ok(reference.Parameter(0))
  assert context.get_return(inner_context, "result") == Ok(reference.Return(0))
  assert context.get_edge(inner_context, reference.Input(0))
    == Ok(reference.Edge(0))

  assert context.get_node(resolved_context, "inner") == Ok(reference.Node(0))
  assert context.get_input(resolved_context, ["inner", "value"])
    == Ok(#(reference.Input(4), reference.Port(0)))
  assert context.get_output(resolved_context, ["inner", "result"])
    == Ok(#(reference.Output(1), reference.Port(0)))

  assert context.get_node(resolved_context, "math") == Ok(reference.Node(1))
  assert context.get_input(resolved_context, ["math", "left"])
    == Ok(#(reference.Input(5), reference.Port(0)))
  assert context.get_output(resolved_context, ["math", "value"])
    == Ok(#(reference.Output(2), reference.Port(0)))

  assert context.get_edge(resolved_context, reference.Input(5))
    == Ok(reference.Edge(0))
  assert context.get_edge(resolved_context, reference.Input(0))
    == Ok(reference.Edge(1))
  assert context.get_edge(resolved_context, reference.Input(1))
    == Ok(reference.Edge(2))
  assert context.get_edge(resolved_context, reference.Input(2))
    == Ok(reference.Edge(3))
  assert context.get_edge(resolved_context, reference.Input(3))
    == Ok(reference.Edge(4))
}

pub fn resolve_unknown_port_diagnostic_test() {
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownPort("Missing"),
    span: source.Span(start: 7, end: 14),
  )) = resolve_source("value: Missing -> {}", environment.new(), context.new())
}

pub fn resolve_unknown_node_diagnostic_test() {
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownNode("Missing"),
    span: source.Span(start: 4, end: 17),
  )) = resolve_source("-> {value=Missing}", environment.new(), context.new())
}

pub fn resolve_unknown_input_diagnostic_test() {
  let environment = environment.add_port(environment.new(), "Int")

  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownInput(["missing"]),
    span: source.Span(start: 7, end: 15),
  )) = resolve_source("-> {1->.missing}", environment, context.new())
}

pub fn resolve_unknown_output_diagnostic_test() {
  let environment = environment.add_port(environment.new(), "Int")

  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownOutput(["missing", "value"]),
    span: source.Span(start: 13, end: 26),
  )) =
    resolve_source(
      "-> out: Int {missing.value->.out}",
      environment,
      context.new(),
    )
}

pub fn resolve_duplicate_return_diagnostic_test() {
  let environment = environment.add_port(environment.new(), "Int")

  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateReturn("value"),
    span: source.Span(start: 15, end: 25),
  )) =
    resolve_source("-> value: Int, value: Int {}", environment, context.new())
}

pub fn resolve_duplicate_parameter_diagnostic_test() {
  let environment = environment.add_port(environment.new(), "Int")

  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateParameter("value"),
    span: source.Span(start: 12, end: 22),
  )) =
    resolve_source("value: Int, value: Int -> {}", environment, context.new())
}

pub fn resolve_duplicate_supernode_diagnostic_test() {
  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateSupernode("Inner"),
    span: source.Span(start: 16, end: 27),
  )) =
    resolve_source(
      "-> {Inner=-> {} Inner=-> {}}",
      environment.new(),
      context.new(),
    )
}

pub fn resolve_duplicate_node_diagnostic_test() {
  let environment = environment.add_node(environment.new(), "Math")

  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateNode("first"),
    span: source.Span(start: 15, end: 25),
  )) = resolve_source("-> {first=Math first=Math}", environment, context.new())
}

pub fn resolve_duplicate_edge_input_diagnostic_test() {
  let environment = environment.add_port(environment.new(), "Int")

  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateEdgeInput(["out"]),
    span: source.Span(start: 21, end: 28),
  )) =
    resolve_source("-> out: Int {1->.out 2->.out}", environment, context.new())
}

fn resolve_source(document_source, environment, context) {
  let assert Ok(tokens) = lexer.lex(document_source)
  let assert Ok(document) = parser.parse(document_source, tokens)
  resolver.resolve(document, environment, context)
}

fn test_environment() {
  environment.new()
  |> environment.add_ports(["Int", "Float", "String"])
  |> environment.add_node("Math")
  |> environment.add_inputs(reference.Node(0), [
    #("left", reference.Port(0)),
  ])
  |> environment.add_outputs(reference.Node(0), [
    #("value", reference.Port(0)),
  ])
}
