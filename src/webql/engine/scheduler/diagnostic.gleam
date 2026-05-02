pub type DiagnosticKind {
  CycleDetected(remaining: List(String))
  InvalidGraph
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
