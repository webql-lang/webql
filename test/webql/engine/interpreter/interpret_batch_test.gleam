import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_batch
import webql/engine/interpreter/memory/kv
import webql/engine/interpreter/runtime as interpreter_runtime
import webql/resolution

pub fn interpret_batch_with_empty_batch_returns_progress_test() {
  let p = kv.new()
  let assert Ok(result) =
    interpret_batch.interpret([], [], runtime(), p, interpret_inline)
    |> unwrap()
  assert result == p
}

pub fn interpret_batch_short_circuits_on_error_test() {
  let failing_step =
    plan.Step(
      name: "fail",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          resolution.Done(Error(dynamic.string("oops")))
        }),
      ),
    )

  let ok_step =
    plan.Step(
      name: "ok",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          ok(dict.from_list([#("value", dynamic.int(1))]))
        }),
      ),
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
    step: name,
    message:,
  ))) =
    interpret_batch.interpret(
      [failing_step, ok_step],
      [],
      runtime(),
      kv.new(),
      interpret_inline,
    )
    |> unwrap()

  assert name == "fail"
  assert decode.run(message, decode.string) == Ok("oops")
}

fn interpret_inline(_plan, memory, _runtime, _parameters) {
  resolution.Done(Ok(memory))
}

fn ok(values: dict.Dict(String, dynamic.Dynamic)) {
  values
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(key, value) = entry
    #(dynamic.string(key), value)
  })
  |> dynamic.properties()
  |> Ok()
  |> resolution.Done()
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
