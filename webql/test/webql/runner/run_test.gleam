import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/memory
import webql/runner/diagnostic
import webql/runner/run

pub fn run_reports_invalid_parameters_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.InvalidParameters(
    errors: _,
  ))) = run.add_parameters(memory.new(), dynamic.int(1))
}

pub fn run_reports_invalid_step_output_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.InvalidStepOutput(
    step: "op",
    errors: _,
  ))) = run.add_outputs(memory.new(), "op", dynamic.int(1))
}

pub fn run_reports_missing_step_input_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(
    step: "op",
    message: _,
  ))) =
    run.get_inputs(memory.new(), "op", [
      plan.Edge(
        source: plan.Output(path: ["missing"]),
        target: plan.Input(path: ["op", "value"]),
      ),
    ])
}

pub fn run_gets_constant_returns_test() {
  let assert Ok(raw) =
    run.get_returns(memory.new(), [
      plan.Edge(
        source: plan.Literal(value: dynamic.int(99)),
        target: plan.Input(path: ["output"]),
      ),
    ])
  let assert Ok(returns) =
    decode.run(raw, decode.dict(decode.string, decode.dynamic))

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(99)
}

pub fn run_reports_missing_route_return_test() {
  assert run.get_returns(memory.new(), [
      plan.Edge(
        source: plan.Output(path: ["missing"]),
        target: plan.Input(path: ["output"]),
      ),
    ])
    == Error(dynamic.nil())
}
