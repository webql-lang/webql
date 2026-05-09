import gleam/dynamic

pub type DiagnosticKind {
  MissingStepInput(step: String, message: dynamic.Dynamic)
  MissingReturn(message: dynamic.Dynamic)
  RuntimeError(step: String, message: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
