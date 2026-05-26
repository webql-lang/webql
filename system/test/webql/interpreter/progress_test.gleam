import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/interpreter/diagnostic
import webql/interpreter/progress
import webql/memory/kv

pub fn progress_reports_invalid_parameters_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.InvalidParameters(
    errors: _,
  ))) = progress.add_parameters(kv.new(), dynamic.int(1))
}

pub fn progress_reports_invalid_step_output_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.InvalidStepOutput(
    step: "op",
    errors: _,
  ))) = progress.add_outputs(kv.new(), "op", dynamic.int(1))
}

pub fn progress_reports_missing_step_input_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(
    step: "op",
    message: _,
  ))) =
    progress.get_inputs(kv.new(), "op", [
      plan.Edge(
        source: plan.Output(path: ["missing"]),
        target: plan.Input(path: ["op", "value"]),
      ),
    ])
}

pub fn progress_gets_constant_returns_test() {
  let assert Ok(raw) =
    progress.get_returns(kv.new(), [
      plan.Edge(
        source: plan.Static(value: dynamic.int(99)),
        target: plan.Input(path: ["output"]),
      ),
    ])
  let assert Ok(returns) =
    decode.run(raw, decode.dict(decode.string, decode.dynamic))

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(99)
}

pub fn progress_reports_missing_route_return_test() {
  assert progress.get_returns(kv.new(), [
      plan.Edge(
        source: plan.Output(path: ["missing"]),
        target: plan.Input(path: ["output"]),
      ),
    ])
    == Error(dynamic.nil())
}
