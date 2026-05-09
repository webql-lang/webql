import gleam/dynamic
import gleam/list
import webql/engine/assembler/linker/program
import webql/graph

/// Links graph edges into scheduler routes.
pub fn link(edges: List(graph.Edge)) -> List(program.Route) {
  list.map(edges, fn(edge) {
    case edge {
      graph.Edge(from: graph.Output(path: from), to: graph.Input(path: to)) ->
        program.Route(from:, to:)

      graph.Edge(
        from: graph.PrimitiveOutput(value: value),
        to: graph.Input(path: to),
      ) -> program.Constant(value: link_constant(value), to:)
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn link_constant(primitive: graph.Primitive) -> dynamic.Dynamic {
  case primitive {
    graph.IntPrimitive(value:) -> dynamic.int(value)
    graph.FloatPrimitive(value:) -> dynamic.float(value)
    graph.StringPrimitive(value:) -> dynamic.string(value)
  }
}
