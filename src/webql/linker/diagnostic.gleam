pub type DiagnosticKind {
  UnknownOperation(name: String)
  CycleDetected(remaining: List(String))
  InvalidPlan
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
