pub type DiagnosticKind {
  UnknownOperator(name: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
