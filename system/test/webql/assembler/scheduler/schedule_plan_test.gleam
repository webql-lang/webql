import gleam/dict
import gleam/dynamic
import gleam/list
import webql/assembler/linker/program as linker_program
import webql/assembler/plan
import webql/assembler/scheduler/diagnostic
import webql/assembler/scheduler/schedule_plan
import webql/schema

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

  assert routes
    == [
      plan.Constant(value: dynamic.int(0), to: ["normalize", "zero"]),
      plan.Route(from: ["user_id"], to: ["normalize", "value"]),
      plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
      plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
      plan.Route(from: ["posts", "items"], to: ["summary"]),
    ]

  let batch_step_names =
    list.map(batches, fn(batch) {
      let plan.Batch(batch: steps) = batch
      list.map(steps, fn(step) {
        let plan.Step(name:, ..) = step
        name
      })
    })

  assert batch_step_names == [["normalize"], ["user"], ["posts"]]
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

  let assert Ok(result) = schedule_plan.schedule(linker_program)
  let assert [plan.Batch(batch: [step])] = result.batches

  let plan.Step(name: step_name, resolver: step_resolver) = step
  assert step_name == "normalize"

  let inner_names = case step_resolver {
    plan.InlineResolver(plan: inner) ->
      list.map(inner.batches, fn(b) {
        let plan.Batch(batch: inner_steps) = b
        list.map(inner_steps, fn(s) {
          let plan.Step(name: s_name, ..) = s
          s_name
        })
      })
    plan.FunctionResolver(_) -> []
  }

  assert inner_names == [["add"]]
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
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}
