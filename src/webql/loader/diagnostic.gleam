import gleam/json

pub type DiagnosticKind {
  JsonDecodeError(kind: json.DecodeError)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
