import gleam/dynamic
import gleam/list
import webql/assembler/linker/program
import webql/graph

/// Links graph edges into scheduler routes.
pub fn link(edges: List(graph.Edge)) -> List(program.Route) {
  list.map(edges, fn(edge) {
    case edge {
      graph.Edge(
        source: graph.Output(path: from),
        target: graph.Input(path: to),
      ) -> program.Route(from:, to:)

      graph.Edge(
        source: graph.Static(value: value),
        target: graph.Input(path: to),
      ) -> program.Constant(value: link_constant(value), to:)
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
