import gleam/dynamic
import gleam/result
import webql/assembler/plan
import webql/engine
import webql/memory
import webql/runner/diagnostic
import webql/runner/run

/// Runs a step in a batch.
pub fn run(
  step: plan.Step(task),
  edges: List(plan.Edge),
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  run_plan,
) -> task {
  engine.handle_start_step(fn() {
    use inputs <- result.try(run.get_inputs(memory, step.name, edges))
    run_step(step, inputs, engine, memory, run_plan)
  })
}

// PRIVATE FUNCTIONS
// =================
fn run_step(
  step: plan.Step(task),
  inputs: dynamic.Dynamic,
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  run_plan,
) {
  use results <- result.try(case step.node {
    plan.Node(resolver:) -> Ok(resolver.resolver(inputs))

    plan.Supernode(plan:) -> run_inline(inputs, plan, engine, memory, run_plan)
  })

  Ok(
    engine.handle_finish_step(results, fn(result) {
      case result {
        Ok(outputs) -> run.add_outputs(memory, step.name, outputs)

        Error(message) ->
          Error(
            diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
              step: step.name,
              message:,
            )),
          )
      }
    }),
  )
}

fn run_inline(
  inputs: dynamic.Dynamic,
  plan: plan.Plan(task),
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  run_plan,
) {
  let results = run_plan(plan, memory.new(), engine, inputs)

  Ok(
    engine.handle_finish_plan(results, fn(memory) {
      case run.get_returns(memory, plan.edges) {
        Ok(returns) -> Ok(returns)
        Error(message) ->
          Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
      }
    }),
  )
}
