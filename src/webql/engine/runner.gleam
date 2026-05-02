import gleam/dict
import gleam/dynamic
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/run_plan

pub opaque type Runner {
  Runner(plan: plan.Plan)
}

/// Creates a new runner instance from an executable plan.
pub fn new(plan: plan.Plan) -> Runner {
  Runner(plan:)
}

/// Runs an executable plan.
pub fn run(
  runner: Runner,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  run_plan.run(runner.plan, parameters)
}
