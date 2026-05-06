import gleam/dict
import gleam/dynamic
import gleam/list
import webql/document
import webql/runtime/engine/linker/plan as linker_plan
import webql/runtime/engine/plan
import webql/runtime/engine/scheduler/diagnostic
import webql/runtime/engine/scheduler/schedule_plan

pub fn schedule_plan_builds_executable_plan_test() {
  let linker_plan =
    linker_plan.Plan(
      nodes: dict.from_list([
        #("normalize", linker_plan.FunctionResolver(resolver())),
        #("user", linker_plan.FunctionResolver(resolver())),
        #("posts", linker_plan.FunctionResolver(resolver())),
      ]),
      routes: [
        linker_plan.Constant(value: dynamic.int(0), to: ["normalize", "zero"]),
        linker_plan.Route(from: ["user_id"], to: ["normalize", "value"]),
        linker_plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
        linker_plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
        linker_plan.Route(from: ["posts", "items"], to: ["summary"]),
      ],
    )

  let assert Ok(plan.Plan(routes:, batches:)) =
    schedule_plan.schedule(linker_plan)

  let assert [
    plan.Constant(value: _, to: ["normalize", "zero"]),
    plan.Route(from: ["user_id"], to: ["normalize", "value"]),
    plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
    plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
    plan.Route(from: ["posts", "items"], to: ["summary"]),
  ] = routes

  let assert [
    plan.Batch(batch: [plan.Step(name: "normalize", resolver: _)]),
    plan.Batch(batch: [plan.Step(name: "user", resolver: _)]),
    plan.Batch(batch: [plan.Step(name: "posts", resolver: _)]),
  ] = batches
}

pub fn schedule_plan_batches_independent_nodes_test() {
  let linker_plan =
    linker_plan.Plan(
      nodes: dict.from_list([
        #("left", linker_plan.FunctionResolver(resolver())),
        #("right", linker_plan.FunctionResolver(resolver())),
      ]),
      routes: [],
    )

  let assert Ok(plan.Plan(batches: [plan.Batch(batch:)], ..)) =
    schedule_plan.schedule(linker_plan)

  let names =
    list.map(batch, fn(step) {
      let plan.Step(name:, ..) = step
      name
    })

  assert list.contains(names, "left")
  assert list.contains(names, "right")
}

pub fn schedule_plan_schedules_inline_resolvers_test() {
  let inline_plan =
    linker_plan.Plan(
      nodes: dict.from_list([#("add", linker_plan.FunctionResolver(resolver()))]),
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
    schedule_plan.schedule(linker_plan)

  let assert plan.Step(
    name: "normalize",
    resolver: plan.InlineResolver(plan: plan.Plan(
      batches: [plan.Batch(batch: [plan.Step(name: "add", resolver: _)])],
      ..,
    )),
  ) = step
}

pub fn schedule_plan_reports_cycles_test() {
  let linker_plan =
    linker_plan.Plan(
      nodes: dict.from_list([
        #("left", linker_plan.FunctionResolver(resolver())),
        #("right", linker_plan.FunctionResolver(resolver())),
      ]),
      routes: [
        linker_plan.Route(from: ["left", "value"], to: ["right", "value"]),
        linker_plan.Route(from: ["right", "value"], to: ["left", "value"]),
      ],
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.CycleDetected(
    remaining:,
  ))) = schedule_plan.schedule(linker_plan)

  assert list.contains(remaining, "left")
  assert list.contains(remaining, "right")
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) { Ok(dict.new()) })
}
