import gleam/dynamic
import gleam/list
import webql/graph
import webql/plan

/// Links graph edges into executable plan edges.
pub fn link(edges: List(graph.Edge)) -> List(plan.Edge) {
  list.map(edges, fn(edge) {
    case edge {
      graph.Edge(
        source: graph.Output(path: source),
        target: graph.Input(path: target),
      ) ->
        plan.Edge(
          source: plan.Output(path: source),
          target: plan.Input(path: target),
        )

      graph.Edge(
        source: graph.Literal(value:),
        target: graph.Input(path: target),
      ) ->
        plan.Edge(
          source: plan.Literal(value: link_value(value)),
          target: plan.Input(path: target),
        )
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn link_value(value: graph.Value) -> dynamic.Dynamic {
  case value {
    graph.Int(value:) -> dynamic.int(value)
    graph.Float(value:) -> dynamic.float(value)
    graph.String(value:) -> dynamic.string(value)
  }
}
