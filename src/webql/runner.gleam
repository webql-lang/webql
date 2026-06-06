import gleam/dynamic
import webql/assembler/plan
import webql/engine
import webql/memory
import webql/runner/run_plan

pub opaque type Runner(task) {
  Runner(plan: plan.Plan(task))
}

/// Creates a new runner instance from an executable plan.
pub fn new(plan: plan.Plan(task)) -> Runner(task) {
  Runner(plan:)
}

/// Runs an executable plan.
pub fn run(
  runner: Runner(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), error),
  parameters: dynamic.Dynamic,
) -> task {
  run_plan.run(runner.plan, memory, engine, parameters)
}
