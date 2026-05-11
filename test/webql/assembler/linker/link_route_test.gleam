import gleam/dynamic
import webql/assembler/linker/link_route
import webql/assembler/linker/program
import webql/graph

pub fn link_route_links_output_edges_test() {
  let edge =
    graph.Edge(
      from: graph.Output(path: ["user", "id"]),
      to: graph.Input(path: ["posts", "user_id"]),
    )

  assert link_route.link([edge])
    == [program.Route(from: ["user", "id"], to: ["posts", "user_id"])]
}

pub fn link_route_links_int_constants_test() {
  let edge =
    graph.Edge(
      from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
      to: graph.Input(path: ["add", "r"]),
    )

  assert link_route.link([edge])
    == [program.Constant(value: dynamic.int(1), to: ["add", "r"])]
}

pub fn link_route_links_float_constants_test() {
  let edge =
    graph.Edge(
      from: graph.PrimitiveOutput(value: graph.FloatPrimitive(1.1)),
      to: graph.Input(path: ["add", "r"]),
    )

  assert link_route.link([edge])
    == [program.Constant(value: dynamic.float(1.1), to: ["add", "r"])]
}

pub fn link_route_links_string_constants_test() {
  let edge =
    graph.Edge(
      from: graph.PrimitiveOutput(value: graph.StringPrimitive("one")),
      to: graph.Input(path: ["format", "name"]),
    )

  assert link_route.link([edge])
    == [program.Constant(value: dynamic.string("one"), to: ["format", "name"])]
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
      program.Route(from: ["user_id"], to: ["user", "id"]),
      program.Route(from: ["user", "id"], to: ["summary"]),
    ]
}
