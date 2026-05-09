import webql/engine/assembler/linker/plan as linker_plan
import webql/engine/assembler/plan
import webql/engine/assembler/scheduler/diagnostic
import webql/engine/assembler/scheduler/schedule_plan

pub opaque type Scheduler {
  Scheduler(plan: linker_plan.Plan)
}

/// Creates a new scheduler instance from a linker plan.
pub fn new(plan: linker_plan.Plan) -> Scheduler {
  Scheduler(plan:)
}

/// Schedules a linker plan.
pub fn schedule(
  scheduler: Scheduler,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  schedule_plan.schedule(scheduler.plan)
}
