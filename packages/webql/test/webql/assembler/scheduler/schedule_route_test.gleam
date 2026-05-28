import gleam/dict
import gleam/dynamic
import gleam/set
import webql/assembler/linker/program
import webql/assembler/scheduler/schedule_route

pub fn schedule_route_builds_node_dependencies_test() {
  let dependencies =
    dict.from_list([
      #("normalize", set.new()),
      #("user", set.new()),
      #("posts", set.new()),
      #("stats", set.new()),
      #("format", set.new()),
    ])

  let dependencies =
    dependencies
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["user_id"]),
      target: program.Input(path: ["normalize", "value"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["normalize", "value"]),
      target: program.Input(path: ["user", "id"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["user", "id"]),
      target: program.Input(path: ["posts", "user_id"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["posts", "items"]),
      target: program.Input(path: ["stats", "posts"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["user", "name"]),
      target: program.Input(path: ["format", "name"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["stats", "count"]),
      target: program.Input(path: ["format", "post_count"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["format", "text"]),
      target: program.Input(path: ["summary"]),
    ))

  assert dependencies
    == dict.from_list([
      #("normalize", set.new()),
      #("user", set.from_list(["normalize"])),
      #("posts", set.from_list(["user"])),
      #("stats", set.from_list(["posts"])),
      #("format", set.from_list(["user", "stats"])),
    ])
}

pub fn schedule_route_ignores_boundaries_and_missing_nodes_test() {
  let dependencies =
    dict.from_list([
      #("left", set.new()),
      #("right", set.new()),
    ])

  let dependencies =
    dependencies
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["input"]),
      target: program.Input(path: ["right", "value"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["left", "value"]),
      target: program.Input(path: ["output"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["missing", "value"]),
      target: program.Input(path: ["right", "value"]),
    ))
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["left", "value"]),
      target: program.Input(path: ["missing", "value"]),
    ))

  assert dependencies
    == dict.from_list([
      #("left", set.new()),
      #("right", set.new()),
    ])
}

pub fn schedule_route_ignores_self_dependencies_test() {
  let dependencies = dict.from_list([#("math", set.new())])

  let dependencies =
    dependencies
    |> schedule_route.schedule(program.Edge(
      source: program.Output(path: ["math", "value"]),
      target: program.Input(path: ["math", "l"]),
    ))

  assert dependencies == dict.from_list([#("math", set.new())])
}

pub fn schedule_route_ignores_constants_test() {
  let dependencies = dict.from_list([#("math", set.new())])

  let dependencies =
    dependencies
    |> schedule_route.schedule(program.Edge(
      source: program.Literal(value: dynamic.int(1)),
      target: program.Input(path: ["math", "r"]),
    ))

  assert dependencies == dict.from_list([#("math", set.new())])
}
