pub type DiagnosticKind {
  CycleDetected(remaining: List(String))
  InvalidPlan
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
