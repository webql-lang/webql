import gleam/dynamic
import gleam/list
import webql/engine/linker/plan
import webql/graph

/// Links graph edges into scheduler routes.
pub fn link(edges: List(graph.Edge)) -> List(plan.Route) {
  list.map(edges, fn(edge) {
    case edge {
      graph.Edge(from: graph.Output(path: from), to: graph.Input(path: to)) ->
        plan.Route(from:, to:)

      graph.Edge(
        from: graph.PrimitiveOutput(value: value),
        to: graph.Input(path: to),
      ) -> plan.Constant(value: link_primitive(value), to:)
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn link_primitive(primitive: graph.Primitive) -> dynamic.Dynamic {
  case primitive {
    graph.IntPrimitive(value:) -> dynamic.int(value)
    graph.FloatPrimitive(value:) -> dynamic.float(value)
    graph.StringPrimitive(value:) -> dynamic.string(value)
  }
}
