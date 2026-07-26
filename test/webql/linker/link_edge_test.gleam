import gleam/dynamic
import webql/graph
import webql/linker/link_edge
import webql/program

pub fn link_edge_links_outputs_and_literals_test() {
  let edges = [
    graph.Edge(
      source: graph.Output(path: ["left", "value"]),
      target: graph.Input(path: ["right", "value"]),
    ),
    graph.Edge(
      source: graph.Literal(value: graph.Int(1)),
      target: graph.Input(path: ["right", "integer"]),
    ),
    graph.Edge(
      source: graph.Literal(value: graph.Float(1.1)),
      target: graph.Input(path: ["right", "float"]),
    ),
    graph.Edge(
      source: graph.Literal(value: graph.String("one")),
      target: graph.Input(path: ["right", "string"]),
    ),
  ]

  assert link_edge.link(edges)
    == [
      program.Edge(
        source: program.Output(path: ["left", "value"]),
        target: program.Input(path: ["right", "value"]),
      ),
      program.Edge(
        source: program.Literal(value: dynamic.int(1)),
        target: program.Input(path: ["right", "integer"]),
      ),
      program.Edge(
        source: program.Literal(value: dynamic.float(1.1)),
        target: program.Input(path: ["right", "float"]),
      ),
      program.Edge(
        source: program.Literal(value: dynamic.string("one")),
        target: program.Input(path: ["right", "string"]),
      ),
    ]
}
