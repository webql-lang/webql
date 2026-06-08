import webql/compiler/reference
import webql/compiler/source

pub type DiagnosticKind {
  UnknownSupernode(reference: reference.Supernode)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  TypeMismatch(expected: reference.Port, found: reference.Port)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
