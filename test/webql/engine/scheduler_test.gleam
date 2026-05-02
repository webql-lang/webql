import gleam/dict
import webql/document
import webql/engine/linker/plan as linker_plan
import webql/engine/plan
import webql/engine/scheduler

pub fn scheduler_returns_executable_plan_test() {
  let resolver = document.Resolver(resolver: fn(_inputs) { dict.new() })

  let linker_plan =
    linker_plan.Plan(
      nodes: dict.from_list([
        #("normalize", linker_plan.FunctionResolver(resolver)),
        #("user", linker_plan.FunctionResolver(resolver)),
        #("posts", linker_plan.FunctionResolver(resolver)),
        #("stats", linker_plan.FunctionResolver(resolver)),
        #("format", linker_plan.FunctionResolver(resolver)),
      ]),
      routes: [
        linker_plan.Route(from: ["user_id"], to: ["normalize", "value"]),
        linker_plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
        linker_plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
        linker_plan.Route(from: ["posts", "items"], to: ["stats", "posts"]),
        linker_plan.Route(from: ["user", "name"], to: ["format", "name"]),
        linker_plan.Route(from: ["stats", "count"], to: [
          "format",
          "post_count",
        ]),
        linker_plan.Route(from: ["format", "text"], to: ["summary"]),
      ],
    )

  let assert Ok(plan.Plan(routes:, batches:)) =
    linker_plan
    |> scheduler.new()
    |> scheduler.schedule()

  let assert [
    plan.Route(from: ["user_id"], to: ["normalize", "value"]),
    plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
    plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
    plan.Route(from: ["posts", "items"], to: ["stats", "posts"]),
    plan.Route(from: ["user", "name"], to: ["format", "name"]),
    plan.Route(from: ["stats", "count"], to: ["format", "post_count"]),
    plan.Route(from: ["format", "text"], to: ["summary"]),
  ] = routes

  let assert [
    plan.Batch(batch: [plan.Step(name: "normalize", resolver: _)]),
    plan.Batch(batch: [plan.Step(name: "user", resolver: _)]),
    plan.Batch(batch: [plan.Step(name: "posts", resolver: _)]),
    plan.Batch(batch: [plan.Step(name: "stats", resolver: _)]),
    plan.Batch(batch: [plan.Step(name: "format", resolver: _)]),
  ] = batches
}

pub fn scheduler_schedules_inline_resolvers_test() {
  let resolver = document.Resolver(resolver: fn(_inputs) { dict.new() })

  let inline_plan =
    linker_plan.Plan(
      nodes: dict.from_list([#("add", linker_plan.FunctionResolver(resolver))]),
      routes: [],
    )

  let linker_plan =
    linker_plan.Plan(
      nodes: dict.from_list([
        #("normalize", linker_plan.InlineResolver(plan: inline_plan)),
      ]),
      routes: [],
    )

  let assert Ok(plan.Plan(batches: [plan.Batch(batch: [step])], ..)) =
    linker_plan
    |> scheduler.new()
    |> scheduler.schedule()

  let assert plan.Step(
    name: "normalize",
    resolver: plan.InlineResolver(plan: plan.Plan(
      batches: [plan.Batch(batch: [plan.Step(name: "add", resolver: _)])],
      ..,
    )),
  ) = step
}
