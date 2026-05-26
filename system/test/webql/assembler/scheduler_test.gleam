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
        #("normalize", linker_program.FunctionResolver(resolver)),
        #("user", linker_program.FunctionResolver(resolver)),
        #("posts", linker_program.FunctionResolver(resolver)),
        #("stats", linker_program.FunctionResolver(resolver)),
        #("format", linker_program.FunctionResolver(resolver)),
      ]),
      routes: [
        linker_program.Route(from: ["user_id"], to: ["normalize", "value"]),
        linker_program.Route(from: ["normalize", "value"], to: ["user", "id"]),
        linker_program.Route(from: ["user", "id"], to: ["posts", "user_id"]),
        linker_program.Route(from: ["posts", "items"], to: ["stats", "posts"]),
        linker_program.Route(from: ["user", "name"], to: ["format", "name"]),
        linker_program.Route(from: ["stats", "count"], to: [
          "format",
          "post_count",
        ]),
        linker_program.Route(from: ["format", "text"], to: ["summary"]),
      ],
    )

  let s = scheduler.new(prog)
  let assert Ok(result) = scheduler.schedule(s)
  let plan.Plan(routes:, batches:) = result

  assert routes
    == [
      plan.Route(from: ["user_id"], to: ["normalize", "value"]),
      plan.Route(from: ["normalize", "value"], to: ["user", "id"]),
      plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
      plan.Route(from: ["posts", "items"], to: ["stats", "posts"]),
      plan.Route(from: ["user", "name"], to: ["format", "name"]),
      plan.Route(from: ["stats", "count"], to: ["format", "post_count"]),
      plan.Route(from: ["format", "text"], to: ["summary"]),
    ]

  let batch_step_names =
    list.map(batches, fn(batch) {
      let plan.Batch(batch: steps) = batch
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
        #("add", linker_program.FunctionResolver(resolver)),
      ]),
      routes: [],
    )

  let prog =
    linker_program.Program(
      nodes: dict.from_list([
        #("normalize", linker_program.InlineResolver(program: inline_prog)),
      ]),
      routes: [],
    )

  let s = scheduler.new(prog)
  let assert Ok(result) = scheduler.schedule(s)
  let assert [plan.Batch(batch: [step])] = result.batches

  let plan.Step(name: step_name, resolver: step_resolver) = step
  assert step_name == "normalize"

  let inner_names = case step_resolver {
    plan.InlineResolver(plan: inner) ->
      list.map(inner.batches, fn(b) {
        let plan.Batch(batch: batch_steps) = b
        list.map(batch_steps, fn(batch_step) {
          let plan.Step(name: n, ..) = batch_step
          n
        })
      })
    plan.FunctionResolver(_) -> []
  }

  assert inner_names == [["add"]]
}

fn empty_resolver() {
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}
