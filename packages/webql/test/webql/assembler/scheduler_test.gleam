import gleam/dict
import gleam/dynamic
import gleam/list
import webql/assembler/linker/program as linker_program
import webql/assembler/plan
import webql/assembler/scheduler
import webql/schema

pub fn scheduler_returns_executable_plan_test() {
  let resolver = empty_resolver()

  let prog =
    linker_program.Program(
      nodes: dict.from_list([
        #("normalize", linker_program.Node(resolver)),
        #("user", linker_program.Node(resolver)),
        #("posts", linker_program.Node(resolver)),
        #("stats", linker_program.Node(resolver)),
        #("format", linker_program.Node(resolver)),
      ]),
      edges: [
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
          target: linker_program.Input(path: ["stats", "posts"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["user", "name"]),
          target: linker_program.Input(path: ["format", "name"]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["stats", "count"]),
          target: linker_program.Input(path: [
            "format",
            "post_count",
          ]),
        ),
        linker_program.Edge(
          source: linker_program.Output(path: ["format", "text"]),
          target: linker_program.Input(path: ["summary"]),
        ),
      ],
    )

  let s = scheduler.new(prog)
  let assert Ok(result) = scheduler.schedule(s)
  let plan.Plan(edges:, batches:) = result

  assert edges
    == [
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
        target: plan.Input(path: ["stats", "posts"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["user", "name"]),
        target: plan.Input(path: ["format", "name"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["stats", "count"]),
        target: plan.Input(path: ["format", "post_count"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["format", "text"]),
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

  assert batch_step_names
    == [["normalize"], ["user"], ["posts"], ["stats"], ["format"]]
}

pub fn scheduler_schedules_inline_resolvers_test() {
  let resolver = empty_resolver()

  let inline_prog =
    linker_program.Program(
      nodes: dict.from_list([
        #("add", linker_program.Node(resolver)),
      ]),
      edges: [],
    )

  let prog =
    linker_program.Program(
      nodes: dict.from_list([
        #("normalize", linker_program.Supernode(program: inline_prog)),
      ]),
      edges: [],
    )

  let s = scheduler.new(prog)
  let assert Ok(result) = scheduler.schedule(s)
  let assert [plan.Batch(steps: [step])] = result.batches

  let plan.Step(name: step_name, node: step_resolver) = step
  assert step_name == "normalize"

  let inner_names = case step_resolver {
    plan.Supernode(plan: inner) ->
      list.map(inner.batches, fn(b) {
        let plan.Batch(steps: batch_steps) = b
        list.map(batch_steps, fn(batch_step) {
          let plan.Step(name: n, ..) = batch_step
          n
        })
      })
    plan.Node(_) -> []
  }

  assert inner_names == [["add"]]
}

fn empty_resolver() {
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}
