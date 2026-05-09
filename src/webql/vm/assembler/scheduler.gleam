import webql/vm/assembler/linker/plan as linker_plan
import webql/vm/assembler/plan
import webql/vm/assembler/scheduler/diagnostic
import webql/vm/assembler/scheduler/schedule_plan

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
