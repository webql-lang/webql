pub type DiagnosticKind {
  MissingStepInput(step: String, input: String)
  MissingReturn(output: String)
  RuntimeError(step: String, message: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
