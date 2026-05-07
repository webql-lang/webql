import gleam/dict
import gleam/dynamic
import gleam/set
import webql/engine/system/linker/plan
import webql/engine/system/scheduler/schedule_route

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
    |> schedule_route.schedule(
      plan.Route(from: ["user_id"], to: ["normalize", "value"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["posts", "items"], to: ["stats", "posts"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["user", "name"], to: ["format", "name"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["stats", "count"], to: ["format", "post_count"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["format", "text"], to: ["summary"]),
    )

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
    |> schedule_route.schedule(
      plan.Route(from: ["input"], to: ["right", "value"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["left", "value"], to: ["output"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["missing", "value"], to: ["right", "value"]),
    )
    |> schedule_route.schedule(
      plan.Route(from: ["left", "value"], to: ["missing", "value"]),
    )

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
    |> schedule_route.schedule(
      plan.Route(from: ["math", "value"], to: ["math", "l"]),
    )

  assert dependencies == dict.from_list([#("math", set.new())])
}

pub fn schedule_route_ignores_constants_test() {
  let dependencies = dict.from_list([#("math", set.new())])

  let dependencies =
    dependencies
    |> schedule_route.schedule(
      plan.Constant(value: dynamic.int(1), to: ["math", "r"]),
    )

  assert dependencies == dict.from_list([#("math", set.new())])
}
