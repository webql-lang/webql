import webql/graph
import webql/runtime/engine/linker/link_route
import webql/runtime/engine/linker/plan

pub fn link_route_links_output_edges_test() {
  let edge =
    graph.Edge(
      from: graph.Output(path: ["user", "id"]),
      to: graph.Input(path: ["posts", "user_id"]),
    )

  assert link_route.link([edge])
    == [plan.Route(from: ["user", "id"], to: ["posts", "user_id"])]
}

pub fn link_route_links_int_constants_test() {
  let edge =
    graph.Edge(
      from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
      to: graph.Input(path: ["add", "r"]),
    )

  let assert [plan.Constant(value: _, to: ["add", "r"])] =
    link_route.link([edge])
}

pub fn link_route_links_float_constants_test() {
  let edge =
    graph.Edge(
      from: graph.PrimitiveOutput(value: graph.FloatPrimitive(1.1)),
      to: graph.Input(path: ["add", "r"]),
    )

  let assert [plan.Constant(value: _, to: ["add", "r"])] =
    link_route.link([edge])
}

pub fn link_route_links_string_constants_test() {
  let edge =
    graph.Edge(
      from: graph.PrimitiveOutput(value: graph.StringPrimitive("one")),
      to: graph.Input(path: ["format", "name"]),
    )

  let assert [plan.Constant(value: _, to: ["format", "name"])] =
    link_route.link([edge])
}

pub fn link_route_links_edges_test() {
  let edges = [
    graph.Edge(
      from: graph.Output(path: ["user_id"]),
      to: graph.Input(path: ["user", "id"]),
    ),
    graph.Edge(
      from: graph.Output(path: ["user", "id"]),
      to: graph.Input(path: ["summary"]),
    ),
  ]

  assert link_route.link(edges)
    == [
      plan.Route(from: ["user_id"], to: ["user", "id"]),
      plan.Route(from: ["user", "id"], to: ["summary"]),
    ]
}
