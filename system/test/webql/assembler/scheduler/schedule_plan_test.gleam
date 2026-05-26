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
        #("normalize", linker_program.Node(resolver())),
        #("user", linker_program.Node(resolver())),
        #("posts", linker_program.Node(resolver())),
      ]),
      edges: [
        linker_program.Edge(
          source: linker_program.Static(value: dynamic.int(0)),
          target: linker_program.Input(path: ["normalize", "zero"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["user_id"]),
          target: linker_program.Input(path: ["normalize", "value"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["normalize", "value"]),
          target: linker_program.Input(path: ["user", "id"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["user", "id"]),
          target: linker_program.Input(path: ["posts", "user_id"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["posts", "items"]),
          target: linker_program.Input(path: ["summary"]),
        ),
      ],
    )

  let assert Ok(plan.Plan(edges:, batches:)) =
    schedule_plan.schedule(linker_program)

  assert edges
    == [
      plan.Edge(
        source: plan.Static(value: dynamic.int(0)),
        target: plan.Input(path: ["normalize", "zero"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["user_id"]),
        target: plan.Input(path: ["normalize", "value"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["normalize", "value"]),
        target: plan.Input(path: ["user", "id"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["user", "id"]),
        target: plan.Input(path: ["posts", "user_id"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["posts", "items"]),
        target: plan.Input(path: ["summary"]),
      ),
    ]

  let batch_step_names =
    list.map(batches, fn(steps) {
      let plan.Batch(steps: steps) = steps
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
        #("left", linker_program.Node(resolver())),
        #("right", linker_program.Node(resolver())),
      ]),
      edges: [],
    )

  let assert Ok(plan.Plan(batches: [plan.Batch(steps:)], ..)) =
    schedule_plan.schedule(linker_program)

  let names =
    list.map(steps, fn(step) {
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
        #("add", linker_program.Node(resolver())),
      ]),
      edges: [],
    )

  let linker_program =
    linker_program.Program(
      nodes: dict.from_list([
        #("normalize", linker_program.Supernode(program: inline_plan)),
      ]),
      edges: [],
    )

  let assert Ok(result) = schedule_plan.schedule(linker_program)
  let assert [plan.Batch(steps: [step])] = result.batches

  let plan.Step(name: step_name, node: step_resolver) = step
  assert step_name == "normalize"

  let inner_names = case step_resolver {
    plan.Supernode(plan: inner) ->
      list.map(inner.batches, fn(b) {
        let plan.Batch(steps: inner_steps) = b
        list.map(inner_steps, fn(s) {
          let plan.Step(name: s_name, ..) = s
          s_name
        })
      })
    plan.Node(_) -> []
  }

  assert inner_names == [["add"]]
}

pub fn schedule_plan_reports_cycles_test() {
  let linker_program =
    linker_program.Program(
      nodes: dict.from_list([
        #("left", linker_program.Node(resolver())),
        #("right", linker_program.Node(resolver())),
      ]),
      edges: [
        linker_program.Edge(
          source: linker_program.Output(path: ["left", "value"]),
          target: linker_program.Input(path: ["right", "value"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["right", "value"]),
          target: linker_program.Input(path: ["left", "value"]),
        ),
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
