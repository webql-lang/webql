import gleam/dynamic
import gleam/dynamic/decode

pub type DiagnosticKind {
  MissingStepInput(step: String, message: dynamic.Dynamic)
  MissingReturn(message: dynamic.Dynamic)
  InvalidReturn(errors: List(decode.DecodeError))
  RuntimeError(step: String, message: dynamic.Dynamic)
  InvalidStepOutput(step: String, errors: List(decode.DecodeError))
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
