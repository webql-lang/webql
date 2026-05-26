import gleam/dynamic
import webql/assembler/linker/link_route
import webql/assembler/linker/program
import webql/graph

pub fn link_route_links_output_edges_test() {
  let edge =
    graph.Edge(
      source: graph.Output(path: ["user", "id"]),
      target: graph.Input(path: ["posts", "user_id"]),
    )

  assert link_route.link([edge])
    == [
      program.Edge(
        source: program.Output(path: ["user", "id"]),
        target: program.Input(path: ["posts", "user_id"]),
      ),
    ]
}

pub fn link_route_links_int_constants_test() {
  let edge =
    graph.Edge(
      source: graph.Static(value: graph.Int(1)),
      target: graph.Input(path: ["add", "r"]),
    )

  assert link_route.link([edge])
    == [
      program.Edge(
        source: program.Static(value: dynamic.int(1)),
        target: program.Input(path: ["add", "r"]),
      ),
    ]
}

pub fn link_route_links_float_constants_test() {
  let edge =
    graph.Edge(
      source: graph.Static(value: graph.Float(1.1)),
      target: graph.Input(path: ["add", "r"]),
    )

  assert link_route.link([edge])
    == [
      program.Edge(
        source: program.Static(value: dynamic.float(1.1)),
        target: program.Input(path: ["add", "r"]),
      ),
    ]
}

pub fn link_route_links_string_constants_test() {
  let edge =
    graph.Edge(
      source: graph.Static(value: graph.String("one")),
      target: graph.Input(path: ["format", "name"]),
    )

  assert link_route.link([edge])
    == [
      program.Edge(
        source: program.Static(value: dynamic.string("one")),
        target: program.Input(path: ["format", "name"]),
      ),
    ]
}

pub fn link_route_links_edges_test() {
  let edges = [
    graph.Edge(
      source: graph.Output(path: ["user_id"]),
      target: graph.Input(path: ["user", "id"]),
    ),
    graph.Edge(
      source: graph.Output(path: ["user", "id"]),
      target: graph.Input(path: ["summary"]),
    ),
  ]

  assert link_route.link(edges)
    == [
      program.Edge(
        source: program.Output(path: ["user_id"]),
        target: program.Input(path: ["user", "id"]),
      ),
      program.Edge(
        source: program.Output(path: ["user", "id"]),
        target: program.Input(path: ["summary"]),
      ),
    ]
}
