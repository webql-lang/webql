import gleam/dict
import gleam/dynamic
import webql/runtime/engine/plan
import webql/runtime/engine/traverser/diagnostic
import webql/runtime/engine/traverser/traverse_plan

pub opaque type Traverser {
  Traverser(plan: plan.Plan)
}

/// Creates a new traverser instance from an executable plan.
pub fn new(plan: plan.Plan) -> Traverser {
  Traverser(plan:)
}

/// Runs an executable plan.
pub fn traverse(
  traverser: Traverser,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  traverse_plan.traverse(traverser.plan, parameters)
}
