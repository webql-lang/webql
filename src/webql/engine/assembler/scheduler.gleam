import webql/engine/assembler/linker/program as linker_program
import webql/engine/assembler/plan
import webql/engine/assembler/scheduler/diagnostic
import webql/engine/assembler/scheduler/schedule_plan

pub opaque type Scheduler {
  Scheduler(plan: linker_program.Program)
}

/// Creates a new scheduler instance from a linker program.
pub fn new(plan: linker_program.Program) -> Scheduler {
  Scheduler(plan:)
}

/// Schedules a linker program.
pub fn schedule(
  scheduler: Scheduler,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  schedule_plan.schedule(scheduler.plan)
}
