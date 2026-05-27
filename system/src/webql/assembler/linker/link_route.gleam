import gleam/dynamic
import gleam/list
import webql/assembler/linker/program
import webql/graph

/// Links graph edges into scheduler program edges.
pub fn link(edges: List(graph.Edge)) -> List(program.Edge) {
  list.map(edges, fn(edge) {
    case edge {
      graph.Edge(
        source: graph.Output(path: from),
        target: graph.Input(path: to),
      ) ->
        program.Edge(
          source: program.Output(path: from),
          target: program.Input(path: to),
        )

      graph.Edge(
        source: graph.Literal(value: value),
        target: graph.Input(path: to),
      ) ->
        program.Edge(
          source: program.Literal(value: link_constant(value)),
          target: program.Input(path: to),
        )
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn link_constant(value: graph.Value) -> dynamic.Dynamic {
  case value {
    graph.Int(value:) -> dynamic.int(value)
    graph.Float(value:) -> dynamic.float(value)
    graph.String(value:) -> dynamic.string(value)
  }
}
