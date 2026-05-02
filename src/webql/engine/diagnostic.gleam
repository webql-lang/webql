import webql/engine/linker/diagnostic as linker_diagnostic
import webql/engine/runner/diagnostic as runner_diagnostic
import webql/engine/scheduler/diagnostic as scheduler_diagnostic

pub type DiagnosticKind {
  LinkerDiagnostic(kind: linker_diagnostic.DiagnosticKind)
  SchedulerDiagnostic(kind: scheduler_diagnostic.DiagnosticKind)
  RunnerDiagnostic(kind: runner_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
