pub type DiagnosticKind {
  MissingStepInput(step: String)
  MissingReturn
  RuntimeError(step: String, message: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
