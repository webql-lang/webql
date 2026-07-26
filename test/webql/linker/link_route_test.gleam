import gleam/dict
import gleam/set
import webql/graph
import webql/linker/link_route

pub fn link_route_builds_node_dependencies_test() {
  let dependencies =
    dict.new()
    |> dict.insert("normalize", set.new())
    |> dict.insert("user", set.new())
    |> dict.insert("posts", set.new())
    |> dict.insert("stats", set.new())
    |> dict.insert("format", set.new())

  let dependencies =
    dependencies
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["user_id"]),
      target: graph.Input(path: ["normalize", "value"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["normalize", "value"]),
      target: graph.Input(path: ["user", "id"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["user", "id"]),
      target: graph.Input(path: ["posts", "user_id"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["posts", "items"]),
      target: graph.Input(path: ["stats", "posts"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["user", "name"]),
      target: graph.Input(path: ["format", "name"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["stats", "count"]),
      target: graph.Input(path: ["format", "post_count"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["format", "text"]),
      target: graph.Input(path: ["summary"]),
    ))

  assert dependencies
    == dict.new()
    |> dict.insert("normalize", set.new())
    |> dict.insert("user", set.from_list(["normalize"]))
    |> dict.insert("posts", set.from_list(["user"]))
    |> dict.insert("stats", set.from_list(["posts"]))
    |> dict.insert("format", set.from_list(["user", "stats"]))
}

pub fn link_route_ignores_boundaries_and_missing_nodes_test() {
  let dependencies =
    dict.new()
    |> dict.insert("left", set.new())
    |> dict.insert("right", set.new())

  let dependencies =
    dependencies
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["input"]),
      target: graph.Input(path: ["right", "value"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["left", "value"]),
      target: graph.Input(path: ["output"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["missing", "value"]),
      target: graph.Input(path: ["right", "value"]),
    ))
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["left", "value"]),
      target: graph.Input(path: ["missing", "value"]),
    ))

  assert dependencies
    == dict.new()
    |> dict.insert("left", set.new())
    |> dict.insert("right", set.new())
}

pub fn link_route_ignores_self_dependencies_test() {
  let dependencies = dict.insert(dict.new(), "math", set.new())

  let dependencies =
    dependencies
    |> link_route.link(graph.Edge(
      source: graph.Output(path: ["math", "value"]),
      target: graph.Input(path: ["math", "l"]),
    ))

  assert dependencies == dict.insert(dict.new(), "math", set.new())
}

pub fn link_route_ignores_constants_test() {
  let dependencies = dict.insert(dict.new(), "math", set.new())

  let dependencies =
    dependencies
    |> link_route.link(graph.Edge(
      source: graph.Literal(value: graph.Int(1)),
      target: graph.Input(path: ["math", "r"]),
    ))

  assert dependencies == dict.insert(dict.new(), "math", set.new())
}
