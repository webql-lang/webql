import webql/engine/system/diagnostic as system_diagnostic

pub type DiagnosticKind {
  SystemDiagnostic(kind: system_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
