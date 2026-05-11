import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/document
import webql/interpreter/diagnostic
import webql/interpreter/interpret_step
import webql/interpreter/sandbox

pub fn interpret_step_reports_runtime_error_test() {
  let step =
    plan.Step(
      name: "fail",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          sandbox.fail(dynamic.string("oops"))
        }),
      ),
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
    step: name,
    message:,
  ))) =
    step
    |> interpret_step.interpret(
      [],
      sandbox.engine(),
      sandbox.memory(),
      interpret_inline,
    )
    |> sandbox.result()

  assert name == "fail"
  assert decode.run(message, decode.string) == Ok("oops")
}

pub fn interpret_step_reports_missing_step_input_test() {
  let step =
    plan.Step(
      name: "op",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) { sandbox.output(inputs) }),
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
      sandbox.engine(),
      sandbox.memory(),
      interpret_inline,
    )
    |> sandbox.result()

  assert s == "op"
}

fn interpret_inline(_plan, memory, _runtime, _parameters) {
  sandbox.memory_task(Ok(memory))
}
