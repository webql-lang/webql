import gleam/dynamic
import webql/assembler/plan
import webql/engine
import webql/interpreter/interpret_plan
import webql/memory

pub opaque type Interpreter(task) {
  Interpreter(plan: plan.Plan(task))
}

/// Creates a new interpreter instance from an executable plan.
pub fn new(plan: plan.Plan(task)) -> Interpreter(task) {
  Interpreter(plan:)
}

/// Runs an executable plan.
pub fn interpret(
  interpreter: Interpreter(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), error),
  parameters: dynamic.Dynamic,
) -> task {
  interpret_plan.interpret(interpreter.plan, memory, engine, parameters)
}
