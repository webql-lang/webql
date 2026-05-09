import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_batch
import webql/engine/interpreter/sandbox
import webql/resolution

pub fn interpret_batch_with_empty_batch_returns_progress_test() {
  let p = sandbox.memory()
  let assert Ok(result) =
    interpret_batch.interpret([], [], sandbox.runtime(), p, interpret_inline)
    |> sandbox.result()
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
      sandbox.runtime(),
      sandbox.memory(),
      interpret_inline,
    )
    |> sandbox.result()

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
