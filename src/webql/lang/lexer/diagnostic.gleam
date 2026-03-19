import webql/lang/source/position

pub type DiagnosticKind {
  IllegalToken
  UnterminatedString
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: position.Span)
}
