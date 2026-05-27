import webql/compiler/reference
import webql/compiler/source

pub type DiagnosticKind {
  TypeMismatch(expected: reference.Port, found: reference.Port)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
