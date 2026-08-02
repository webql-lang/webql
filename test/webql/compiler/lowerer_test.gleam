import webql/compiler/lowerer
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/graph

pub fn lower_document_test() {
  let inner_graph =
    resolver.Graph(
      parameters: [resolved_parameter("value", "Int")],
      returns: [resolved_return("result", "Int")],
      nodes: [],
      edges: [
        resolved_edge(resolved_output(["value"]), resolved_input(["result"])),
      ],
      span: test_span(),
    )

  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [resolved_parameter("input", "Int")],
        returns: [
          resolved_return("output", "Int"),
          resolved_return("integer", "Int"),
          resolved_return("float", "Float"),
          resolved_return("text", "String"),
        ],
        nodes: [
          resolver.Supernode(
            name: "Inner",
            graph: inner_graph,
            reference: reference.Supernode(0),
            span: test_span(),
          ),
          resolver.Node(
            name: "inner",
            node: "Inner",
            reference: reference.Node(0),
            span: test_span(),
          ),
          resolver.Node(
            name: "math",
            node: "Math",
            reference: reference.Node(1),
            span: test_span(),
          ),
        ],
        edges: [
          resolved_edge(
            resolved_output(["math", "value"]),
            resolved_input(["output"]),
          ),
          resolved_edge(
            resolved_literal(resolver.Int(
              name: "Int",
              value: 42,
              span: test_span(),
            )),
            resolved_input(["inner", "value"]),
          ),
          resolved_edge(
            resolved_literal(resolver.Float(
              name: "Float",
              value: 1.25,
              span: test_span(),
            )),
            resolved_input(["float"]),
          ),
          resolved_edge(
            resolved_literal(resolver.String(
              name: "String",
              value: "hello",
              span: test_span(),
            )),
            resolved_input(["text"]),
          ),
        ],
        span: test_span(),
      ),
      reference: reference.Document(0),
      span: test_span(),
    )

  let lowerer = lowerer.new(document)

  let lowered_inner_graph =
    graph.Graph(
      parameters: [graph.Parameter(name: "value", port: "Int")],
      returns: [graph.Return(name: "result", port: "Int")],
      nodes: [],
      edges: [
        graph.Edge(
          source: graph.Output(path: ["value"]),
          target: graph.Input(path: ["result"]),
        ),
      ],
    )

  assert lowerer.lower(lowerer)
    == graph.Graph(
      parameters: [graph.Parameter(name: "input", port: "Int")],
      returns: [
        graph.Return(name: "output", port: "Int"),
        graph.Return(name: "integer", port: "Int"),
        graph.Return(name: "float", port: "Float"),
        graph.Return(name: "text", port: "String"),
      ],
      nodes: [
        graph.Supernode(name: "inner", graph: lowered_inner_graph),
        graph.Node(name: "math", node: "Math"),
      ],
      edges: [
        graph.Edge(
          source: graph.Output(path: ["math", "value"]),
          target: graph.Input(path: ["output"]),
        ),
        graph.Edge(
          source: graph.Literal(value: graph.Int(42)),
          target: graph.Input(path: ["inner", "value"]),
        ),
        graph.Edge(
          source: graph.Literal(value: graph.Float(1.25)),
          target: graph.Input(path: ["float"]),
        ),
        graph.Edge(
          source: graph.Literal(value: graph.String("hello")),
          target: graph.Input(path: ["text"]),
        ),
      ],
    )
}

fn resolved_parameter(name: String, port: String) -> resolver.Parameter {
  resolver.Parameter(
    name:,
    port: resolved_port(port),
    reference: reference.Parameter(0),
    span: test_span(),
  )
}

fn resolved_return(name: String, port: String) -> resolver.Return {
  resolver.Return(
    name:,
    port: resolved_port(port),
    reference: reference.Return(0),
    span: test_span(),
  )
}

fn resolved_port(name: String) -> resolver.Port {
  resolver.Port(name:, reference: reference.Port(0), span: test_span())
}

fn resolved_edge(
  source: resolver.Source,
  target: resolver.Target,
) -> resolver.Edge {
  resolver.Edge(
    source:,
    target:,
    reference: reference.Edge(0),
    span: test_span(),
  )
}

fn resolved_output(path: List(String)) -> resolver.Source {
  resolver.Output(path:, reference: reference.Output(0), span: test_span())
}

fn resolved_literal(value: resolver.Value) -> resolver.Source {
  resolver.Literal(value:, port: reference.Port(0), span: test_span())
}

fn resolved_input(path: List(String)) -> resolver.Target {
  resolver.Input(path:, reference: reference.Input(0), span: test_span())
}

fn test_span() -> source.Span {
  source.Span(start: 0, end: 0)
}
