import gleam/dynamic/decode

pub type DiagnosticKind {
  DynamicDecodeError(errors: List(decode.DecodeError))
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
