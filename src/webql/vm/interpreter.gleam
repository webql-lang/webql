import gleam/dict
import gleam/dynamic
import webql/vm/assembler/plan
import webql/vm/interpreter/diagnostic
import webql/vm/interpreter/interpret_plan
import webql/vm/interpreter/memory

pub opaque type Interpreter {
  Interpreter(plan: plan.Plan)
}

/// Creates a new interpreter instance from an executable plan.
pub fn new(plan: plan.Plan) -> Interpreter {
  Interpreter(plan:)
}

/// Runs an executable plan.
pub fn interpret(
  interpreter: Interpreter,
  memory: memory.Memory(a, b),
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  interpret_plan.interpret(interpreter.plan, memory, parameters)
}
