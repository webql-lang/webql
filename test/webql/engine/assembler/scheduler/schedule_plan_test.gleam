import gleam/dict
import gleam/dynamic
import gleam/list
import webql/document
import webql/engine/assembler/linker/program as linker_program
import webql/engine/assembler/plan
import webql/engine/assembler/scheduler/diagnostic
import webql/engine/assembler/scheduler/schedule_plan
import webql/resolution

pub fn schedule_plan_builds_executable_plan_test() {
  let linker_program =
    linker_program.Program(
      nodes: dict.from_list([
        #("normalize", linker_program.FunctionResolver(resolver())),
        #("user", linker_program.FunctionResolver(resolver())),
        #("posts", linker_program.FunctionResolver(resolver())),
      ]),
      routes: [
        linker_program.Constant(value: dynamic.int(0), to: ["normalize", "zero"]),
        linker_program.Route(from: ["user_id"], to: ["normalize", "value"]),
        linker_program.Route(from: ["normalize", "value"], to: ["user", "id"]),
        linker_program.Route(from: ["user", "id"], to: ["posts", "user_id"]),
        linker_program.Route(from: ["posts", "items"], to: ["summary"]),
      ],
    )

  let assert Ok(plan.Plan(routes:, batches:)) =
    schedule_plan.schedule(linker_program)

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
  let linker_program =
    linker_program.Program(
      nodes: dict.from_list([
        #("left", linker_program.FunctionResolver(resolver())),
        #("right", linker_program.FunctionResolver(resolver())),
      ]),
      routes: [],
    )

  let assert Ok(plan.Plan(batches: [plan.Batch(batch:)], ..)) =
    schedule_plan.schedule(linker_program)

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
    linker_program.Program(
      nodes: dict.from_list([
        #("add", linker_program.FunctionResolver(resolver())),
      ]),
      routes: [],
    )

  let linker_program =
    linker_program.Program(
      nodes: dict.from_list([
        #("normalize", linker_program.InlineResolver(program: inline_plan)),
      ]),
      routes: [],
    )

  let assert Ok(plan.Plan(batches: [plan.Batch(batch: [step])], ..)) =
    schedule_plan.schedule(linker_program)

  let assert plan.Step(
    name: "normalize",
    resolver: plan.InlineResolver(plan: plan.Plan(
      batches: [plan.Batch(batch: [plan.Step(name: "add", resolver: _)])],
      ..,
    )),
  ) = step
}

pub fn schedule_plan_reports_cycles_test() {
  let linker_program =
    linker_program.Program(
      nodes: dict.from_list([
        #("left", linker_program.FunctionResolver(resolver())),
        #("right", linker_program.FunctionResolver(resolver())),
      ]),
      routes: [
        linker_program.Route(from: ["left", "value"], to: ["right", "value"]),
        linker_program.Route(from: ["right", "value"], to: ["left", "value"]),
      ],
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.CycleDetected(
    remaining:,
  ))) = schedule_plan.schedule(linker_program)

  assert list.contains(remaining, "left")
  assert list.contains(remaining, "right")
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) {
    resolution.Done(Ok(dynamic.properties([])))
  })
}
