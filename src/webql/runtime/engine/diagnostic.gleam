import webql/runtime/engine/linker/diagnostic as linker_diagnostic
import webql/runtime/engine/scheduler/diagnostic as scheduler_diagnostic
import webql/runtime/engine/traverser/diagnostic as traverser_diagnostic

pub type DiagnosticKind {
  LinkerDiagnostic(kind: linker_diagnostic.DiagnosticKind)
  SchedulerDiagnostic(kind: scheduler_diagnostic.DiagnosticKind)
  TraverserDiagnostic(kind: traverser_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
