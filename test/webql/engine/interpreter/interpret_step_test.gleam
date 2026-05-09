import gleam/dynamic
import gleam/dynamic/decode
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_step
import webql/engine/interpreter/memory/kv
import webql/engine/interpreter/runtime as interpreter_runtime
import webql/resolution

pub fn interpret_step_reports_runtime_error_test() {
  let step =
    plan.Step(
      name: "fail",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          resolution.Done(Error(dynamic.string("oops")))
        }),
      ),
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
    step: name,
    message:,
  ))) =
    interpret_step.interpret(step, [], runtime(), kv.new(), interpret_inline)
    |> unwrap()

  assert name == "fail"
  assert decode.run(message, decode.string) == Ok("oops")
}

pub fn interpret_step_reports_missing_step_input_test() {
  let step =
    plan.Step(
      name: "op",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) { resolution.Done(Ok(inputs)) }),
      ),
    )

  let routes = [plan.Route(from: ["source"], to: ["op", "x"])]

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(
    step: s,
    message: _message,
  ))) =
    interpret_step.interpret(
      step,
      routes,
      runtime(),
      kv.new(),
      interpret_inline,
    )
    |> unwrap()

  assert s == "op"
}

fn interpret_inline(_plan, memory, _runtime, _parameters) {
  resolution.Done(Ok(memory))
}

fn runtime() {
  interpreter_runtime.Runtime(
    batches: fn(initial, _batches) { resolution.Done(Ok(initial)) },
    steps: run_steps,
    resolve: fn(resolution, next) { resolution.Done(next(unwrap(resolution))) },
    nested: continue,
    complete: continue,
  )
}

fn run_steps(initial, steps, merge) {
  case steps {
    [] -> resolution.Done(Ok(initial))
    [step, ..rest] -> {
      case unwrap(step) {
        Ok(next) -> run_steps(merge(initial, next), rest, merge)
        Error(error) -> resolution.Done(Error(error))
      }
    }
  }
}

fn continue(resolution, next) {
  case unwrap(resolution) {
    Ok(value) -> resolution.Done(next(value))
    Error(error) -> resolution.Done(Error(error))
  }
}

fn unwrap(resolution) {
  let assert resolution.Done(result) = resolution
  result
}
