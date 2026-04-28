import webql/lang/compiler/source

pub type DiagnosticKind {
  IllegalToken
  UnterminatedString
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
