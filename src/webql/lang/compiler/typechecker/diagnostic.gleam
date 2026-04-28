import webql/lang/compiler/reference
import webql/lang/compiler/source

pub type DiagnosticKind {
  TypeMismatch(expected: reference.Typename, found: reference.Typename)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
