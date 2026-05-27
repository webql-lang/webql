pub type DiagnosticKind {
  UnknownOperation(name: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
