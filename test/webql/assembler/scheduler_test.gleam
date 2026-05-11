import gleam/dict
import gleam/dynamic
import webql/assembler/linker/program as linker_program
import webql/assembler/plan
import webql/assembler/scheduler
import webql/document

pub fn scheduler_returns_executable_plan_test() {
  let resolver = empty_resolver()

  let linker_program =
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

  let assert Ok(plan.Plan(routes:, batches:)) =
    linker_program
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
  let resolver = empty_resolver()

  let inline_plan =
    linker_program.Program(
      nodes: dict.from_list([
        #("add", linker_program.FunctionResolver(resolver)),
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
    linker_program
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

fn empty_resolver() {
  document.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}
