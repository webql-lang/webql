pub type DiagnosticKind {
  UnknownNode(name: String)
  CycleDetected(remaining: List(String))
  InvalidProgram
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
