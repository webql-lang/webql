import gleam/dynamic
import gleam/result
import webql/assembler/plan
import webql/engine
import webql/interpreter/diagnostic
import webql/interpreter/progress
import webql/memory

/// Runs a step in a batch.
pub fn interpret(
  step: plan.Step(task),
  routes: List(plan.Route),
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  interpret_plan,
) -> task {
  engine.start_step(fn() {
    use inputs <- result.try(progress.get_inputs(memory, step.name, routes))
    interpret_step(step, inputs, engine, memory, interpret_plan)
  })
}

// PRIVATE FUNCTIONS
// =================
fn interpret_step(
  step: plan.Step(task),
  inputs: dynamic.Dynamic,
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  interpret_plan,
) {
  use results <- result.try(case step.resolver {
    plan.FunctionResolver(function:) -> Ok(function.resolver(inputs))

    plan.InlineResolver(plan:) ->
      interpret_inline(inputs, plan, engine, memory, interpret_plan)
  })

  Ok(
    engine.finish_step(results, fn(result) {
      case result {
        Ok(outputs) -> progress.add_outputs(memory, step.name, outputs)

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

fn interpret_inline(
  inputs: dynamic.Dynamic,
  plan: plan.Plan(task),
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  interpret_plan,
) {
  let results = interpret_plan(plan, memory.new(), engine, inputs)

  Ok(
    engine.finish_plan(results, fn(memory) {
      case progress.get_returns(memory, plan.routes) {
        Ok(returns) -> Ok(returns)
        Error(message) ->
          Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
      }
    }),
  )
}
