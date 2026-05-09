import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/memory
import webql/engine/interpreter/progress
import webql/engine/interpreter/runtime
import webql/resolution

/// Runs a step in a batch.
pub fn interpret(
  step: plan.Step,
  routes: List(plan.Route),
  runtime: runtime.Runtime(memory.Memory(storage), _, diagnostic.Diagnostic),
  memory: memory.Memory(storage),
  interpret_plan,
) -> resolution.Resolution(memory.Memory(storage), diagnostic.Diagnostic) {
  case progress.get_inputs(memory, step.name, routes) {
    Ok(inputs) -> interpret_step(step, inputs, runtime, memory, interpret_plan)
    Error(diagnostic) -> resolution.Done(Error(diagnostic))
  }
}

// PRIVATE FUNCTIONS
// =================
fn interpret_step(
  step: plan.Step,
  inputs: dynamic.Dynamic,
  runtime: runtime.Runtime(memory.Memory(storage), _, diagnostic.Diagnostic),
  memory: memory.Memory(storage),
  interpret_plan,
) {
  let plan.Step(name:, resolver:) = step

  case resolver {
    plan.FunctionResolver(function:) ->
      interpret_resolver(name, function, inputs, runtime, memory)

    plan.InlineResolver(plan:) -> {
      case progress.decode(inputs) {
        Ok(inputs) ->
          interpret_inline(name, inputs, plan, runtime, memory, interpret_plan)

        Error(error) -> resolution.Done(Error(error))
      }
    }
  }
}

fn interpret_resolver(
  step: String,
  function: document.Resolver,
  inputs: dynamic.Dynamic,
  runtime: runtime.Runtime(memory.Memory(storage), _, diagnostic.Diagnostic),
  memory: memory.Memory(storage),
) {
  let document.Resolver(resolver:) = function

  inputs
  |> resolver()
  |> runtime.resolve(fn(result) {
    case result {
      Ok(outputs) -> progress.add_outputs(memory, step, outputs)

      Error(message) ->
        Error(diagnostic.Diagnostic(diagnostic.RuntimeError(step:, message:)))
    }
  })
}

fn interpret_inline(
  step: String,
  inputs: dict.Dict(String, dynamic.Dynamic),
  plan: plan.Plan,
  runtime: runtime.Runtime(memory.Memory(storage), _, diagnostic.Diagnostic),
  memory: memory.Memory(storage),
  interpret_plan,
) {
  let inline_memory = interpret_plan(plan, memory.new(), runtime, inputs)

  runtime.inline(inline_memory, fn(inline_memory) {
    case progress.get_returns(inline_memory, plan.routes) {
      Ok(returns) -> {
        let outputs = progress.encode(returns)
        progress.add_outputs(memory, step, outputs)
      }

      Error(message) ->
        Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
    }
  })
}
