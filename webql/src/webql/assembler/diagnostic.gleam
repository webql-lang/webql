import webql/assembler/linker/diagnostic as linker_diagnostic
import webql/assembler/scheduler/diagnostic as scheduler_diagnostic

pub type DiagnosticKind {
  LinkerDiagnostic(kind: linker_diagnostic.DiagnosticKind)
  SchedulerDiagnostic(kind: scheduler_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
