import webfn/lexer/position

pub type DiagnosticKind {
  IllegalToken
  UnterminatedString
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: position.Span)
}
