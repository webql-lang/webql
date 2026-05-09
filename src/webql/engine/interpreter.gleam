import gleam/dict
import gleam/dynamic
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_plan
import webql/engine/interpreter/memory
import webql/engine/interpreter/runtime
import webql/resolution

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
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(memory.Memory(storage), diagnostic.Diagnostic),
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> resolution.Resolution(dynamic.Dynamic, diagnostic.Diagnostic) {
  interpret_plan.interpret(interpreter.plan, memory, runtime, parameters)
}
