import webql/runtime/engine/diagnostic as engine_diagnostic

pub type DiagnosticKind {
  EngineDiagnostic(kind: engine_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
