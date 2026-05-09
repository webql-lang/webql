import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/memory
import webql/engine/interpreter/progress

/// Runs a step in a batch.
pub fn interpret(
  step: plan.Step,
  routes: List(plan.Route),
  memory: memory.Memory(a, b),
  interpret_plan,
) {
  case progress.get_inputs(memory, step.name, routes) {
    Ok(inputs) -> interpret_step(step, inputs, memory, interpret_plan)
    Error(_nil) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(step: step.name)),
      )
  }
}

// PRIVATE FUNCTIONS
// =================
fn interpret_step(
  step: plan.Step,
  inputs: dict.Dict(String, dynamic.Dynamic),
  memory: memory.Memory(a, b),
  interpret_plan,
) {
  let plan.Step(name:, resolver:) = step

  case resolver {
    plan.FunctionResolver(function:) ->
      interpret_resolver(name, function, inputs, memory)

    plan.InlineResolver(plan:) -> {
      use outputs <- result.try(interpret_plan(plan, memory.new(), inputs))
      Ok(progress.add_outputs(memory, name, outputs))
    }
  }
}

fn interpret_resolver(
  step: String,
  function: document.Resolver,
  inputs: dict.Dict(String, dynamic.Dynamic),
  memory: memory.Memory(a, b),
) {
  let document.Resolver(resolver:) = function

  case resolver(inputs) {
    Ok(outputs) -> Ok(progress.add_outputs(memory, step, outputs))
    Error(message) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.RuntimeError(step:, message:)),
      )
  }
}
