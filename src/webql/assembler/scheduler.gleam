import webql/assembler/linker/program as linker_program
import webql/assembler/plan
import webql/assembler/scheduler/diagnostic
import webql/assembler/scheduler/schedule_plan

pub opaque type Scheduler(task) {
  Scheduler(plan: linker_program.Program(task))
}

/// Creates a new scheduler instance from a linker program.
pub fn new(plan: linker_program.Program(task)) -> Scheduler(task) {
  Scheduler(plan:)
}

/// Schedules a linker program.
pub fn schedule(
  scheduler: Scheduler(task),
) -> Result(plan.Plan(task), diagnostic.Diagnostic) {
  schedule_plan.schedule(scheduler.plan)
}
